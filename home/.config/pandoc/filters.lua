-- pandoc Lua 过滤器（配合 remarkable.yaml / remarkable.tex）
--   1) 让长内联代码（路径/函数名）在 PDF 里可断行，修复溢出
--   2) mermaid 代码块：装了 mermaid-cli(mmdc) 就渲染成图，否则给出占位卡片

------------------------------------------------------------------
-- 1) 长内联代码断点
------------------------------------------------------------------
local Code_filter = {}
if FORMAT:match('latex') then
  local breakchars = { ['/']=true, ['.']=true, [':']=true, ['_']=true, ['-']=true }
  function Code_filter.Code(el)
    local t = el.text
    if #t < 8 then return nil end
    local out, buf = {}, ''
    for i = 1, #t do
      local c = t:sub(i, i)
      buf = buf .. c
      if breakchars[c] and i < #t then
        out[#out+1] = pandoc.Code(buf, el.attr)
        out[#out+1] = pandoc.RawInline('latex', '\\allowbreak{}')
        buf = ''
      end
    end
    if #buf > 0 then out[#out+1] = pandoc.Code(buf, el.attr) end
    if #out <= 1 then return nil end
    return out
  end
end

------------------------------------------------------------------
-- 2) mermaid 代码块
------------------------------------------------------------------
local function has_cmd(c)
  local h = io.popen('command -v ' .. c .. ' 2>/dev/null')
  if not h then return false end
  local r = h:read('*a'); h:close()
  return r ~= nil and r:match('%S') ~= nil
end
local mmdc_ok = has_cmd('mmdc')

local function is_mermaid(el)
  for _, c in ipairs(el.classes) do if c == 'mermaid' then return true end end
  return false
end

local Mermaid_filter = {}
function Mermaid_filter.CodeBlock(el)
  if not (FORMAT:match('latex') and is_mermaid(el)) then return nil end

  if mmdc_ok then
    local home = os.getenv('HOME') or '.'
    local dir = (os.getenv('XDG_CACHE_HOME') or (home .. '/.cache')) .. '/pandoc-mermaid'
    os.execute('mkdir -p ' .. dir)
    local hash = pandoc.utils.sha1(el.text)
    local mmd = dir .. '/' .. hash .. '.mmd'
    local pdf = dir .. '/' .. hash .. '.pdf'
    local f = io.open(mmd, 'w'); f:write(el.text); f:close()
    os.execute('mmdc -i ' .. mmd .. ' -o ' .. pdf .. ' -b transparent >/dev/null 2>&1')
    local ok = io.open(pdf, 'rb')
    if ok then
      local nonempty = ok:seek('end') > 0   -- 渲染产物非空才用，否则退回占位卡片
      ok:close()
      if nonempty then
        return pandoc.RawBlock('latex',
          '\\begin{center}\\includegraphics[width=\\linewidth]{' .. pdf .. '}\\end{center}')
      end
    end
  end

  -- 占位卡片
  local raw =
    '\\begin{mdframed}[linecolor=rmline,linewidth=0.4pt,backgroundcolor=rmraised,roundcorner=3pt,'
    .. 'innerleftmargin=10pt,innerrightmargin=10pt,innertopmargin=7pt,innerbottommargin=7pt]'
    .. '{\\color{rmaccent}\\textbf{架构图（Mermaid）}}\\\\[3pt]'
    .. '{\\color{rminksoft}\\small 此流程图在 PDF 版未内嵌渲染。查看渲染效果：用 HTML/Artifact 版，'
    .. '或安装 mermaid-cli（\\texttt{npm i -g @mermaid-js/mermaid-cli}）后重新导出即自动成图。}'
    .. '\\end{mdframed}'
  return pandoc.RawBlock('latex', raw)
end

------------------------------------------------------------------
-- 3) emoji 通用兜底：正文字体没有的图形字符包进 \rmEmoji（单色 Noto Emoji）
--    remarkable.tex 里 newunicodechar 逐个映射过的字符不受影响（活动字符优先）
------------------------------------------------------------------
local Emoji_filter = {}
if FORMAT:match('latex') then
  local function is_emoji(cp)
    return (cp >= 0x1F000 and cp <= 0x1FAFF)  -- 各类 emoji/图形符号平面
        or (cp >= 0x2600  and cp <= 0x27BF)   -- 杂项符号 + 装饰符号（⚖ ✂ ➔…）
        or (cp >= 0x2B00  and cp <= 0x2BFF)   -- ⭐ ⬆ 等
        or cp == 0x203C or cp == 0x2049       -- ‼ ⁉
        or cp == 0x200D                       -- ZWJ，随组合序列一起进 emoji 字体
  end
  local function split(text)
    local out, buf, mode = {}, {}, nil  -- mode: 'txt' | 'emo'
    local function flush()
      if #buf == 0 then return end
      local s = table.concat(buf)
      if mode == 'emo' then
        out[#out+1] = pandoc.RawInline('latex', '\\rmEmoji{' .. s .. '}')
      else
        out[#out+1] = pandoc.Str(s)
      end
      buf = {}
    end
    for _, cp in utf8.codes(text) do
      if cp ~= 0xFE0F then  -- 变体选择符直接丢弃
        local m = is_emoji(cp) and 'emo' or 'txt'
        if m ~= mode then flush(); mode = m end
        buf[#buf+1] = utf8.char(cp)
      end
    end
    flush()
    return out
  end
  function Emoji_filter.Str(el)
    for _, cp in utf8.codes(el.text) do
      if is_emoji(cp) or cp == 0xFE0F then return split(el.text) end
    end
    return nil
  end
end

return { Code_filter, Mermaid_filter, Emoji_filter }
