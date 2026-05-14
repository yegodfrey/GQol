# GQol - 魔兽世界增强插件 / World of Warcraft Enhancement Addon

GQol 是一个功能全面的魔兽世界增强插件，提供多种实用功能来提升游戏体验。
GQol is a comprehensive World of Warcraft enhancement addon that provides various useful features to enhance your gaming experience.

## 功能列表 / Feature List

- [音频助手](#音频助手) - 快速开关声音和切换音频设备
  Quick sound toggle and audio device switching
- [指南针](#指南针) - 在小地图和世界地图显示朝向指针
  Display direction pointer on minimap and world map
- [区域亮度调节](#区域亮度调节) - 为不同区域设置独立亮度、伽马值和对比度
  Set independent brightness, gamma, and contrast for different zones
- [空格助手](#空格助手) - 快速交互助手，包括任务、对话、交易、进出战场、制造订单等，通过空格键快速确认
  Quick interaction assistant for quests, dialogs, trades, entering/leaving battlegrounds, crafting orders, etc., with quick confirmation via spacebar
- [自由视角](#自由视角) - 进入自由视角模式，无需按住鼠标右键即可调整视角，减少驭龙术等场景下手指疲劳
  Enter free camera mode, no need to hold right mouse button to adjust view, reducing finger fatigue during dragonriding and other scenarios
- [战斗双击选中](#战斗双击选中) - 战斗中必须双击右键才能选中目标，避免转换视角的时候选中错误的目标
  Requires double right-click to select targets in combat, avoiding accidental target selection when rotating the camera
- [目标距离显示](#目标距离显示) - 显示与目标的距离
  Display distance to target
- [集合石助手](#集合石助手) - 队伍申请阶段统一显示的已申请队伍信息，支持快速取消申请；进队显示副本传送法术并统计等待时间和申请次数
  Unified display of applied groups during application phase, supports quick cancellation; displays dungeon teleport spells and tracks wait time and application count when joining a group
- [专业技能标签](#专业技能标签) - 法术书右侧显示专业标签
  Display profession tabs on the right side of the spellbook
- [系统设置](#系统设置) - 保存和加载系统设置与按键绑定
  Save and load system settings and key bindings
- [动作条方案](#动作条方案) - 按专精保存和加载动作条配置
  Save and load action bar configurations by specialization
- [宏管理](#宏管理) - 保存和加载通用宏与职业宏
  Save and load general macros and class macros
- [编辑模式](#编辑模式) - 保存和加载界面布局
  Save and load UI layouts
- [自动Roll点](#自动roll点) - 自动对掉落物品进行需求、贪婪、幻化或放弃操作
  Automatically roll Need, Greed, Transmog, or Pass on loot items

---

## 详细功能介绍 / Detailed Feature Introduction

### 音频助手 / Audio Assistant

音频助手，提供迷你图标用于快速开关游戏声音和切换音频输出设备。
Audio assistant provides a mini icon for quickly toggling game sound and switching audio output devices.

**主要功能 / Main Features:**
- 左键点击：切换游戏声音开关
  Left click: Toggle game sound on/off
- 右键点击：切换音频输出设备（跳过最后一个设备）
  Right click: Switch audio output device (skips last device)
- Shift + 左键拖动：移动图标位置
  Shift + Left drag: Move icon position
- 自定义图标大小
  Customizable icon size
- 支持重置图标位置到默认位置
  Supports resetting icon position to default

**命令 / Commands:**
- `/gqol sound` - 快速切换声音开关
  Quick sound toggle

---

### 指南针 / Compass

在小地图和世界地图上显示玩家朝向的指南针指针。
Displays a compass pointer showing the player's direction on the minimap and world map.

**主要功能 / Main Features:**
- 小地图显示朝向指针
  Displays direction pointer on minimap
- 世界地图显示朝向指针
  Displays direction pointer on world map
- 自定义指针粗细（小地图/世界地图分开设置）
  Customizable pointer thickness (minimap/world map separate settings)
- 自定义刷新间隔
  Customizable refresh interval
- 自定义指针颜色
  Customizable pointer color

---

### 区域亮度调节 / Zone Brightness Adjustment

区域亮度自动调节，可为不同区域设置独立的亮度、伽马值和对比度。
Automatic zone brightness adjustment, allows setting independent brightness, gamma, and contrast for different zones.

**主要功能 / Main Features:**
- 为不同区域保存独立的亮度设置
  Save independent brightness settings for different zones
- 添加当前区域到管理列表
  Add current zone to management list
- 从管理列表移除区域
  Remove zone from management list
- 保存基准亮度配置
  Save baseline brightness configuration
- 自动切换区域亮度
  Automatically switch zone brightness

**命令 / Commands:**
- `/gqol add` - 添加当前区域到管理列表
  Add current zone to management list
- `/gqol del` - 从管理列表移除当前区域
  Remove current zone from management list
- `/gqol save` - 保存当前亮度为基准配置
  Save current brightness as baseline configuration

---

### 空格助手 / Space Assistant

空格键快捷交互助手，使用空格键和数字键 1-5 快速完成各种交互操作。
Spacebar shortcut interaction assistant, use spacebar and number keys 1-5 to quickly complete various interaction operations.

**支持按键 / Supported Keys:**
- 空格键：默认选择第一个选项
  Spacebar: Select first option by default
- 数字键 1-5：选择对应位置的选项
  Number keys 1-5: Select corresponding position option

**支持窗口 / Supported Windows:**
- 任务窗口：接受任务、完成任务
  Quest window: Accept quest, complete quest
- 对话窗口：选择对话选项
  Dialog window: Select dialog options
- 对话框：确认对话框、进入地下城、进入战场、接受邀请、准备确认、角色检查
  Dialog boxes: Confirmation dialogs, enter dungeon, enter battleground, accept invite, ready check, role check
- 战场结果窗口：离开按钮
  Battleground results window: Leave button
- 荣誉等级提升窗口：继续按钮
  Honor level up window: Continue button
- 专业制造窗口：开始订单、创建、完成订单
  Profession crafting window: Start order, create, complete order
- 兼容 PatronOffers 插件
  Compatible with PatronOffers addon

**命令 / Commands:**
- `/gqol sbt` - 快速切换空格助手启用/禁用
  Quick toggle space assistant on/off

---

### 自由视角 / Free Camera

自由视角模式，长按指定按键时释放鼠标视角控制，避免驭龙术等场景下手指疲劳。
Free camera mode, releases mouse camera control when holding specified keys, avoiding finger fatigue during dragonriding and other scenarios.

**主要功能 / Main Features:**
- 自定义触发按键（Ctrl/Shift/Alt）
  Customizable trigger key (Ctrl/Shift/Alt)
- 可调整长按延迟时间
  Adjustable long press delay time
- 长按按键自动进入自由视角
  Long press key to automatically enter free camera
- 松开按键退出自由视角
  Release key to exit free camera

---

### 战斗双击选中 / Combat Double-Click Targeting

战斗中右键双击选中目标，避免旋转视角时误选目标。建议同时开启系统设置中的"左键交互"。
Requires double right-click to select targets in combat, avoiding accidental target selection when rotating the camera. Recommended to also enable "Left Click Interact" in system settings.

**主要功能 / Main Features:**
- 战斗中双击右键选中目标
  Double right-click to select targets in combat
- 防止旋转视角时误选
  Prevents accidental selection when rotating camera
- 兼容系统"左键交互"设置
  Compatible with system "Left Click Interact" setting

---

### 目标距离显示 / Target Distance Display

显示当前目标的距离信息，支持自定义颜色、大小和位置。
Displays distance information to current target, supports customizable colors, size, and position.

**主要功能 / Main Features:**
- 显示与目标的距离
  Display distance to target
- 自定义攻击范围内/外颜色
  Customizable colors for within/outside attack range
- 可调整字体大小
  Adjustable font size
- 可调整框架缩放
  Adjustable frame scale
- 可调整隐藏距离阈值
  Adjustable hide distance threshold
- 锁定/解锁位置
  Lock/unlock position
- 支持重置位置
  Supports position reset

---

### 集合石助手 / Group Finder Assistant

集合石界面助手，在集合石界面显示副本传送按钮、申请队伍统计和正在申请的队伍列表。
Group finder interface assistant, displays dungeon teleport button, application statistics, and list of pending applications in the group finder interface.

**主要功能 / Main Features:**
- 显示副本传送法术按钮（显示冷却时间）
  Displays dungeon teleport spell button (shows cooldown)
- 统计申请次数和等待时间
  Tracks application count and wait time
- 显示正在申请的队伍列表
  Displays list of pending applications
- 可取消正在申请的队伍
  Can cancel pending applications
- 可调整字体大小
  Adjustable font size
- 可调整框架缩放
  Adjustable frame scale
- 支持重置位置
  Supports position reset
- 可拖动移动框架
  Draggable frame

**命令 / Commands:**
- `/gqol show` - 强制显示集合石助手
  Force show group finder assistant
- `/gqol hide` - 隐藏集合石助手
  Hide group finder assistant

---

### 专业技能标签 / Profession Skill Tabs

在法术书右侧显示专业技能标签，方便快速使用专业技能。
Displays profession skill tabs on the right side of the spellbook for quick access to profession skills.

**主要功能 / Main Features:**
- 法术书右侧显示专业标签
  Displays profession tabs on the right side of spellbook
- 点击标签直接使用对应技能
  Click tab to directly use corresponding skill
- 自动识别可用的专业技能
  Automatically identifies available profession skills
- 支持切换飞行模式（如果已学会）
  Supports switching to flight mode (if learned)

---

### 系统设置 / System Settings

保存和加载系统设置（伽马值、亮度、对比度、声音等）以及按键绑定方案，支持登录时自动应用。
Save and load system settings (gamma, brightness, contrast, sound, etc.) and key binding profiles, supports automatic application on login.

**主要功能 / Main Features:**
- 保存当前系统设置
  Save current system settings
- 应用已保存的系统设置
  Apply saved system settings
- 保存和加载按键绑定
  Save and load key bindings
- 支持登录时自动应用
  Supports automatic application on login

---

### 动作条方案 / Action Bar Profiles

按专精保存和加载动作条方案，支持登录或切换专精时自动应用。
Save and load action bar profiles by specialization, supports automatic application on login or specialization switch.

**主要功能 / Main Features:**
- 保存当前专精的动作条配置
  Save current specialization's action bar configuration
- 应用已保存的动作条配置
  Apply saved action bar configuration
- 切换专精时自动应用对应方案
  Automatically apply corresponding profile when switching specialization
- 登录时自动应用当前专精方案
  Automatically apply current specialization profile on login

---

### 宏管理 / Macro Management

保存和加载通用宏及职业宏方案，职业宏按职业分别保存，支持登录时自动应用。
Save and load general macro and class macro profiles, class macros saved separately by class, supports automatic application on login.

**主要功能 / Main Features:**
- 保存和加载通用宏
  Save and load general macros
- 保存和加载职业宏（按职业区分）
  Save and load class macros (separated by class)
- 支持登录时自动应用
  Supports automatic application on login

---

### 编辑模式 / Edit Mode

保存和加载编辑模式布局方案，支持登录时自动应用。
Save and load edit mode layout profiles, supports automatic application on login.

**主要功能 / Main Features:**
- 保存当前编辑模式布局
  Save current edit mode layout
- 应用已保存的布局
  Apply saved layout
- 支持登录和切换专精时自动应用
  Supports automatic application on login and specialization switch

---

### 自动Roll点 / Auto Roll

点击"一键拾取"按钮后，自动对掉落物品进行需求、贪婪或幻化操作（需求 > 贪婪 > 幻化）。
Click the "Auto Loot" button to automatically roll Need, Greed, or Transmog on loot items (Need > Greed > Transmog).

**主要功能 / Main Features:**
- 掉落装备时显示"一键拾取"按钮（屏幕上方）
  Shows "Auto Loot" button when loot becomes available (top of screen)
- 点击按钮后自动处理所有装备
  Click button to automatically process all items
- 固定策略：需求 > 贪婪 > 幻化
  Fixed strategy: Need > Greed > Transmog
- 显示自动Roll点结果通知
  Displays auto roll result notifications

---

## 配置面板 / Configuration Panel

使用 `/gqol` 命令打开配置面板，可以在其中配置所有功能。
Use the `/gqol` command to open the configuration panel, where you can configure all features.
