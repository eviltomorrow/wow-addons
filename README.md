# AntiHarmony（反和谐·基础工具）

面向《魔兽世界》正式服 **12.1.0（Curse of Ula'tek，TOC `120100`，2026-08-27 上线）** 的初始化插件。定位是"地基"插件：反和谐相关能力 + 一批常用基础功能 + 12.1 API 现状整理。

## 目录结构

```
AntiHarmony.toc      TOC 元数据（Interface 120100，SavedVariables 声明）
Core.lua             命名空间、默认值、开关注册表（TOGGLES）、CVar 预设、通用工具
Harmony.lua          反和谐检测（overrideArchive）
AutoActions.lua      自动修理 / 自动卖灰
Info.lua             FPS/耐久度信息面板
CombatIcon.lua       战斗状态图标（按专精风格播放叠加层动画）
Media/               战斗图标贴图（256 个 .tga，部分为后续扩展预留）
Settings.lua         设置面板（Blizzard Settings API）
Commands.lua         /ah 命令
Shortcuts.lua        快捷命令（/rl /fs /qg）
```

## 安装

1. 把本仓库（或仓库内全部文件）复制到 `_retail_/Interface/AddOns/` 下，**文件夹命名为 `AntiHarmony`**（`Media/` 路径硬编码了该文件夹名）；
2. 进入游戏，在角色选择界面确认插件列表中出现 "AntiHarmony" 并勾选启用；
3. 登录角色即生效。默认会应用"模型反和谐、技能队列 180ms"两项设置；
4. 首次安装后请**重启一次游戏**，客户端才会加载 `Media/` 里的战斗图标贴图；
5. 卸载：删除 `Interface/AddOns/AntiHarmony/`，同时在 `WTF/Account/<账号>/SavedVariables/` 删除 `AntiHarmonyDB.lua`。

## 现有功能

### 反和谐（国服）

| 功能 | 实现方式 | 默认 |
| --- | --- | --- |
| 模型/特效还原 | 插件在游戏内设置 `overrideArchive=0`（持久化到 WTF），重启游戏生效 | 开启 |
| 图标还原 | 需自行把未和谐图标放入 `_retail_/Interface/ICONS/`，插件不涉及 | — |

本插件做法：
- 设置面板勾选"模型/特效反和谐"（或 `/ah harmony on`），插件每次进游戏自动写入 `overrideArchive=0`，无需改文件；
- 游戏内 `/ah check` 检测状态并提示是否需重启。

### 基础功能（全部可在设置面板开关）

| 开关 | 行为 | 默认 |
| --- | --- | --- |
| 自动修理 | 打开商人界面时自动修理全部装备（优先公会修理） | 关闭 |
| 自动出售灰色物品 | 打开商人界面时自动卖掉品质为"普通/灰"的物品 | 关闭 |
| 技能队列窗口 | `spellQueueWindow=180`，降低技能预输入窗口 | 开启 |
| 战斗状态图标 | 进战斗瞬间播放职业/专精动画 2s 后隐藏 | 开启 |
| FPS/耐久度面板 | 屏幕显示帧数与装备平均耐久（可拖动） | 开启 |

### FPS/耐久度面板

- 显示 `FPS` 与装备平均耐久百分比（绿 ≥50%、黄 ≥25%、红 <25%）为**一行**，每 0.5s 刷新；
- **圆角**背景（暴雪自带 `Interface/Tooltips/UI-Tooltip-Background` + `UI-Tooltip-Border`，半透明底色），框体**自适应内容宽高**（随文字自动伸缩）；
- 左键按住可拖动，位置会保存（`statusPos`）；默认停靠在小地图左上角；
- 默认跟随 `showStatus` 开关，`/ah fps` 可随时切换。

### 战斗状态图标

- 进/出战斗瞬间（`PLAYER_REGEN_DISABLED` / `PLAYER_REGEN_ENABLED`）在屏幕中央偏上（y≈280）显示当前**职业/专精**图标：主图常驻，`*zdN` 叠加层按**专精风格**动画（约 0.8s）后**直接平滑淡出（约 0.35s）**，总时长约 1.2s；图标尺寸 130×130，并防重入避免连续进出战斗导致的闪烁；
- **进/出战斗效果区分**：进入战斗（`PLAYER_REGEN_DISABLED`）按专精风格正常外扩动画；退出战斗（`PLAYER_REGEN_ENABLED`）叠加层改为**由大收拢到小**的"回收"动画，方向相反、一眼可辨；
- 贴图取自 `Media/`，按 specID 映射，见 `CombatIcon.lua` 的 `SPEC_IMAGES` 表；每个专精条目带 `style` 字段，分四类动画：
  - `swell`（光圈涨缩）：层同步外扩 + 淡出（战士、防骑、兽王猎、元素/增强萨、踏风、浩劫DH 等大图层）
  - `spark`（粒子四散）：层错开时机向外散开 + 淡出（德/术士/DK/暗牧 等分散小元素）
  - `converge`（聚拢）：层由大收拢到小 + 淡出（法师、牧师、贼、恢复萨、武僧、野德/熊/恢复德 等中型居中层）
  - `static`（静态）：仅主图显示后淡出（射击猎、复仇DH）
- 唤魔师无对应资源，不显示；无动画帧的专精（射击猎、复仇DH）走 `static` 风格；
- 默认跟随 `combatIcon` 开关，`/ah combat` 可切换。

### CVar 优化预设（`/ah tune`，手动触发）

```
cameraDistanceMaxZoomFactor = 2.6   视角最大拉远距离
lootUnderMouse = 1                  鼠标悬停拾取
showLootSpam = 1                    显示拾取信息
```

## 影响范围

### 插件会修改哪些 CVar

| CVar | 值 | 生效时机 | 影响 |
| --- | --- | --- | --- |
| `overrideArchive` | 0 | 进游戏（开关开启时） | 加载未和谐模型/特效数据，**重启游戏后当前会话生效** |
| `spellQueueWindow` | 180 | 进游戏（开关开启时） | 技能预输入队列由默认 250ms 缩短为 180ms，连招手感会变紧 |
| `cameraDistanceMaxZoomFactor` | 2.6 | `/ah tune` | 放大视野上限 |
| `lootUnderMouse` | 1 | `/ah tune` | 鼠标指向拾取 |
| `showLootSpam` | 1 | `/ah tune` | 显示拾取信息 |
| `gxWindowed` / `gxMaximize` | 切换 | `/fs` | 窗口化/全屏切换，`gxMaximize` 同步归零避免状态脱钩 |

> CVar 经 `C_CVar.SetCVar` 写入后持久化在 `WTF/Config.wtf`（按角色），**不是**本插件自己的配置；在游戏设置里改动对应项，下次进游戏时若开关仍开启会被插件再次覆盖。

### 自动行为的影响与边界

- **自动修理 / 自动卖灰**：打开任何商人界面时立即执行；卖灰遍历玩家背包（`C_Container.GetContainerNumSlots / GetContainerItemInfo`），按物品品质为"普通"判定、跳过被锁定的物品，用 `C_Container.UseContainerItem` 出售；修理用 `CanMerchantRepair()` 判断、`RepairAllItems(CanGuildBankRepair())` 优先使用公会资金。
- **战斗状态图标**：仅监听 `PLAYER_REGEN_DISABLED` / `PLAYER_REGEN_ENABLED` 显示贴图动画（进=外扩、退=收拢，各约 0.8s 后淡出），**不读取任何战斗数据、不影响战斗行为**，纯表现层。

### 数据与文件

- 插件自身只保存一个**每角色** SavedVariables：`AntiHarmonyDB.lua`，位于 `WTF/Account/<账号>/SavedVariables/`，删除即恢复默认。
- 插件只通过 `C_CVar.SetCVar` 写 CVar（持久化到 `WTF/Config.wtf`），**不修改任何游戏数据文件**；`overrideArchive` 由插件在进游戏时自动写入，重启游戏生效。

### 明确不做的事

- 不读取/不依赖任何 12.1 秘密数据（光环、单位身份、冷却等战斗信息）；
- 不 hook 或改写任何暴雪自带框架（`/qg` 只是主动点击系统按钮）；
- 不涉及图标还原（需自行把未和谐图标放入 `Interface/ICONS/`，插件不提供该类文件）。

## 使用

### 命令速查

| 命令 | 说明 |
| --- | --- |
| `/ah help` | 帮助 |
| `/ah panel` | 打开设置面板 |
| `/ah check` | 反和谐状态检测 |
| `/ah tune` | 应用 CVar 优化预设 |
| `/ah reset` | 恢复默认设置 |
| `/ah repair on\|off` | 开关自动修理 |
| `/ah sell on\|off` | 开关自动出售灰色物品 |
| `/ah harmony on\|off` | 开关模型/特效反和谐（overrideArchive=0） |
| `/ah spellqueue on\|off` | 开关技能队列 180ms |
| `/ah combat on\|off` | 开关战斗状态图标 |
| `/ah fps [on\|off]` | 开关 FPS/耐久面板（不带参数则翻转） |
| `/rl` | 重载界面 |
| `/fs` | 窗口化 / 全屏切换 |
| `/qg` | 交接当前任务（接受/完成） |

### 设置面板

- 路径：`ESC → 选项 → 插件 → 反和谐·基础工具`；
- 面板内可直接开关全部功能、重新检测反和谐状态、一键应用 CVar 优化、恢复默认。

### 模型/特效反和谐

1. 设置面板勾选"模型/特效反和谐"（默认已开启，或 `/ah harmony on`）；
2. 插件每次进游戏自动写入 `overrideArchive=0`（持久化到 `WTF/Config.wtf`）；
3. **重启游戏**后生效，`/ah check` 应显示"已开启"。

图标还原不属于本插件范围：将未和谐图标放入 `_retail_/Interface/ICONS/` 后重启游戏即可。

## 扩展指引

- 新功能：新建 `XXX.lua`，在 TOC 中追加一行，用 `local _, ns = ...` 拿到命名空间。
- 新开关：在 `Core.lua` 的 `ns.defaults.char` 加默认值字段，并在 `ns.TOGGLES` 注册 `{ label, cvar, cvarValue, apply }`——侧效应会自动统一到设置面板、`/ah` 命令与进游戏应用三处。
- 遵守 12.1 安全模型：不要在战斗/大秘境中读取光环、单位身份、冷却等秘密数据；自定义光环展示请迁移到 AuraContainer。

## 12.1.0 API 现状整理

### 版本与安全模型背景

12.0「Midnight」起暴雪实施"插件卸除计划"（Addon Disarmament），12.1 继续收紧：

- **Secret Values（秘密值）**：战斗/副本/大秘境/PvP 中，敏感 API 返回"黑盒"值。addon 代码不能比较、算术运算秘密值，否则 Lua 报错。尝试 `format("%.1s", secret)` 这种精度格式化也已于 12.0.1 起禁止。
- **Forbidden Aspects（禁制面）**：帧对象被标记后，addon 无法安装脚本处理器、注册事件、调用输入类 API 等（见 `Enum.ForbiddenAspect`）。
- **Private Script Objects / Forbidden Partition**：脚本对象可拆分"禁区表"，addon 不可达。

### 12.1 核心变化（对普通 UI 插件影响最大的部分）

- **Aura（光环）全面改造**：新增原生对象 `AuraContainer` / `AuraButton`，addon 通过 `AddAuraGroup/AddAuraSlot` 声明过滤规则，由系统负责追踪/排序/布局，addon 只做展示。传统 `SecureAuraHeaderTemplate` 已在正式服移除。
- **UnitAura API 收紧**：`C_UnitAura`、`C_TooltipInfo` 中按索引/slot/instanceID 获取光环的 API，在光环为秘密时 addon 调用会直接 Lua 报错；`UNIT_AURA` 事件在秘密时负载全秘密。按 spellID/名称查询仍可用。
- **Unit 身份保密**：`UnitClass/UnitClassBase/UnitRace/UnitSex/UnitInRaid/UnitIsGroupLeader` 等一批 API，目标身份保密时返回秘密值；`GetGuildInfo` 不再接受复合单位 token；`UnitName` 在 PvP 对局中不再返回秘密值。
- **冷却时长对象**：旧 `C_ActionBar.GetActionCooldownRemaining*`、`C_Spell.GetSpellCooldownRemaining*`、`C_UnitAuras.GetAuraDurationRemaining*` 已移除，统一改用 duration object（`SetCooldownFromDurationObject`、`EvaluateRemainingDuration` 等）。`ActionButton_ApplyCooldown` 不再通过安全委托执行。

### 12.1 新增 / 更名 / 移除（精选）

**新增**
- `Frame:SetOnUpdateMode(mode)`：控制 OnUpdate 触发时机（Disabled / RunWhenVisible / RunWhenVisibleOnce / RunOnce / RunAlways）
- SVG 纹理 + `VectorGraphics` 对象类型（高精度渲染；暂不支持旋转/遮罩/texCoord）
- 径向遮罩：`Texture/StatusBar:SetRadialProgressBar*`
- TOC 新增 `[Bootstrap]` 指令（Load-on-Demand 插件指定启动即加载的文件）
- `C_Roleset` 角色组系统（`ApplyRolesetFilters` 等），帧可挂 `IsRolesetFiltered` / `alwaysBlocked`
- `FrameScriptObject:HasAccessConstraints` / `CanBeAccessedInContext`
- `Frame:ResizeToBoundsRect`（按子对象边界自动调整大小）
- 新 CVar 一批：`tooltipShowAuraSpellIDs`、`nameplateForceShowUnitName`、`worldMapShowCursorCoords` 等（共新增 23 个）

**更名**
- `UIParentLoadAddOn` → `LoadAddOnWithErrorHandling`
- `CanAccessObject` → `FrameScriptObject:CanBeAccessedInContext`
- `C_UnitAuras.AddPrivateAuraAppliedSound` → `AddAuraSound`（并支持 added/applied/removed 阶段）

**移除（Removed，19 项全局 API 中的一部分）**
- `C_BattleNet` 一批好友标签/称号好友 API（旧称号好友系统重构）
- `C_Discord` 一批 Discord 集成 API
- `C_CVar.AreCVarsLoaded`、`C_Browser.CloseFullscreenBrowser`
- `C_CooldownViewer.GetGroupBuffItems`

**废弃（Deprecated）**
- `getglobal` / `setglobal`
- `RaidNotice_AddMessage/Clear` → `RaidWarningUtil`/`RaidWarningFrameMixin`
- `C_DyeColor.GetDyeColorForItem*` → 复数版 `GetDyeColorsForItem*`

完整 diff 见 [warcraft.wiki.gg/wiki/Patch_12.1.0/API_changes](https://warcraft.wiki.gg/wiki/Patch_12.1.0/API_changes)，源数据比对：[Gethe/wow-ui-source](https://github.com/Gethe/wow-ui-source/compare/12.0.7..12.1.0)、[Ketho/BlizzardInterfaceResources](https://github.com/Ketho/BlizzardInterfaceResources/compare/12.0.7...12.1.0)。

### 本插件用到的 12.1 安全 API

- CVar：`C_CVar.GetCVar / SetCVar`
- 设置面板：`Settings.RegisterCanvasLayoutCategory / RegisterAddOnCategory / OpenToCategory`
- 交互：`AcceptQuest / CompleteQuest / CanAcceptQuest / CanCompleteQuest`
- 商人：`CanMerchantRepair / RepairAllItems / CanGuildBankRepair / C_Container.GetContainerNumSlots / C_Container.GetContainerItemInfo / C_Container.UseContainerItem`
- 其他：`ReloadUI / InCombatLockdown / GetLocale / GetFramerate / GetInventoryItemDurability / Enum.ItemQuality.Poor`

## 高清图标

[高清图标: https://github.com/AcidWeb/Clean-Icons-Mechagnome-Edition](https://github.com/AcidWeb/Clean-Icons-Mechagnome-Edition)