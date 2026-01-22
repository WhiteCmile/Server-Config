" --- 基础显示配置 ---
set number              " 显示行号
set relativenumber      " 显示相对行号（可选，方便跳转，如果不习惯可以删掉）
set cursorline          " 高亮当前行
set wrap                " 自动换行
set showcmd             " 在状态栏显示正在输入的命令

" --- 代码高亮与颜色 ---
syntax on               " 开启语法高亮
filetype plugin indent on " 自动识别文件类型并加载对应缩进规则
set t_Co=256            " 开启256色支持

" --- 缩进配置 (Tab 改为 4 空格) ---
set tabstop=4           " 设置 Tab 占用 4 个空格的宽度
set shiftwidth=4        " 设置自动缩进时使用的空格数
set softtabstop=4       " 按退格键时一次删除 4 个空格
set expandtab           " 将 Tab 键自动转换为空格 (推荐，防止不同编辑器排版混乱)
set autoindent          " 继承前一行的缩进

" --- 搜索配置 ---
set hlsearch            " 高亮显示搜索结果
set incsearch           " 边输入边高亮
set ignorecase          " 搜索时忽略大小写
set smartcase           " 如果搜索词包含大写，则不忽略大小写

" --- 编码配置 ---
set encoding=utf-8      " 使用 utf-8 编码
