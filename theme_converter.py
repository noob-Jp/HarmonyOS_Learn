import os
import glob

# 预定义的颜色替换映射
REPLACEMENTS = {
    # 背景
    "'#0F172A'": "'#F4F6F9'", # 页面大背景
    "'rgba(255,255,255,0.04)'": "'#FFFFFF'",
    "'rgba(255,255,255,0.05)'": "'#FFFFFF'",
    "'rgba(255,255,255,0.06)'": "'#FFFFFF'",
    "'rgba(255,255,255,0.07)'": "'#FFFFFF'",
    "'rgba(0,0,0,0.25)'": "'#FFFFFF'", # 一些深色小卡片
    "'rgba(0,0,0,0.4)'": "'#F8FAFC'", # 代码块背景

    # 边框
    "'rgba(255,255,255,0.06)'": "'rgba(0,0,0,0.05)'",
    "'rgba(255,255,255,0.07)'": "'rgba(0,0,0,0.05)'",
    "'rgba(255,255,255,0.08)'": "'rgba(0,0,0,0.05)'",
    "'rgba(255,255,255,0.1)'": "'rgba(0,0,0,0.08)'",

    # 文字颜色 (高对比 -> 深色)
    "'#F1F5F9'": "'#1E293B'", # 一级标题
    "'#CBD5E1'": "'#334155'", # 二级标题
    "'#94A3B8'": "'#475569'", # 次要文字
    # '#64748B' 保持不变
    "'#475569'": "'#94A3B8'", # 最淡文字

    # 代码块
    "'#A5F3FC'": "'#0284C7'", # 代码块文字

    # Header 返回按钮和特殊符号
    "'rgba(255,255,255,0.03)'": "'#FFFFFF'"
}

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original = content
    for old, new in REPLACEMENTS.items():
        content = content.replace(old, new)
        
    # 特殊处理：将卡片的阴影从发光色改成浅灰色
    content = content.replace("color: `${card.color}44`", "color: 'rgba(0,0,0,0.08)'")

    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f'Updated {os.path.basename(filepath)}')

target_dir = r'd:\DevEcoStudioProjects\MyApplication2\entry\src\main\ets\pages'
for file in glob.glob(os.path.join(target_dir, '*.ets')):
    process_file(file)

print('Done!')
