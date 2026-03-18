## 1. 介绍 (Introduction)
一个智能厨房助手。它帮助用户管理冰箱里的食材，并根据现有库存推荐食谱，最后提供辅助烹饪模式以减少食物浪费。

## 2. 应用架构 (Application Architecture)

### 2.1. 概述 (Overview)
本应用采用**模块化分层架构**，利用 Flutter 框架构建全响应式前端视图。后端核心依赖 **Firebase Firestore** 提供实时数据持久化支持。架构设计的核心驱动力是“多源数据聚合”，通过集成百度AI图像识别、百度翻译、Edamam 营养库以及 Spoonacular 食谱引擎，将用户录入的食材转化为结构化的营养数据与可执行的烹饪建议。逻辑层级分为：
*   **表示层 (Presentation Layer)**：基于 Widget 的 UI 构建，通过 StreamBuilder 实现与云端数据的动态绑定。
*   **服务层 (Service Layer)**：包含 `NutritionService` 和 `DatabaseService`，负责 API 链式调用及 Firestore 读写。
*   **数据层 (Data Layer)**：涵盖远程 NoSQL 存储、本地 CSV 自动补全字典及 JSON 季节性知识库。

### 2.2. 数据模型 (Data Model)
系统定义了四个核心实体模型，确保数据在不同 API 与 Screen 间流畅流转：
*   **Ingredient (食材)**: 核心实体。模型包含名称、数量、数量单位、由 Edamam API 计算得到的卡路里值、过期日期（Timestamp）以及用于业务去重的唯一标识。
*   **Recipe (食谱)**: 聚合模型。除了包含标题、图片和详细步骤外，重点通过 `usedIngredients` 和 `missedIngredients` 字段区分用户现有库存与执行该食谱所需的差值。
*   **ShoppingItem (购物项)**: 映射自 `/shopping_cart` 集合，记录商品名和建议采购数量。
*   **SeasonalFood (季节性食材)**: 映射自本地 `season_foods.json`。包含别名列表（用于匹配搜索）、所属季节区间以及保存策略建议。

### 2.3. 数据管理 (Data Management)

#### 2.3.1. Cloud Firestore (云数据库)
作为主要的非关系型数据源，采用用户 ID（UID）隔离存储路径：
*   **路径设计**: `/artifacts/nutriscan-app-v1/users/{userId}/inventory` 为设备间同步的最小单位。
*   **响应式流流**: `InventoryScreen` 订阅 Firestore 操作流，当用户完成手动输入、扫码录入或编辑后，UI 层通过 `snapshots()` 机制实现增量更新。

#### 2.3.2. Shared Preferences (本地偏好设置)
用于持久化用户粒度的配置信息，减少冷启动时的 API 调用：
*   **主题方案**: 存储用户选择的四季主题索引（Spring/Summer/Autumn/Winter）。
*   **API 策略**: 存储用户在 Settings 中选定的食谱源（Spoonacular 或 TheMealDB 模式）。

#### 2.3.3. 本地存储与资产 (Local Storage & Assets)
*   **智能自动补全**: 通过 `ingredient_list_service.dart` 实时加载 `assets/data/ingredient_list.csv`，在用户手动输入时提供字典级模糊匹配。
*   **离线季节库**: 存储 `season_foods.json` 数据，用于 `SeasonalListScreen` 的本地检索，不依赖网络即可获取季节性建议。

### 2.4. 外部服务 (External Services)

#### 2.4.1. Firebase Authentication
实现用户身份标识管理，为 Firestore 存储提供安全的 UID 上下文，支持匿名登录及标准邮箱认证。

#### 2.4.2. 食材解析与营养 (Edamam & OpenFoodFacts)
*   **Edamam Nutrition API**: `HomeScreen` 将清理后的英文食材关键词（及数量）发送至 API，获取动态热量计算结果。
*   **OpenFoodFacts API**: 在 `BarcodeScannerScreen` 扫描到条码后，向世界食品库发起请求，换取商品名称及能量（kJ/kcal）数据。

#### 2.4.3. 百度 AI 服务 (Baidu AI Capability)
系统利用百度云服务解决图片化交互与跨语言障碍：
*   **食材识别 (Ingredient Classify)**: 通过 Base64 上传拍摄图片，获取前 20 个高置信度食材标签。
*   **百度翻译 (Baidu Translate)**: 作为核心中转。由于营养与食谱 API 仅支持英文，系统自动将识别到的中文标签实时翻译为英文，确保跨平台数据的语义一致性。

#### 2.4.4. 食谱引擎 (Spoonacular & TheMealDB)
*   **Spoonacular API**: 用于执行“基于库存食材匹配食谱”逻辑。接收库存关键词列表，计算匹配度并返回缺失食材清单。
*   **TheMealDB**: 作为“Free API”模式的数据源，提供基础食材检索及食谱详情（含烹饪步骤及视频链接）。

### 2.5. 逻辑实现深度 (Logic Implementation)
*   **智能去重逻辑**: 在 `HomeScreen` 保存食材时，`food_validator.dart` 会对比新输入名称与现有库存。若检测到同名且未过期的食材，系统会自动合并现有 `quantity`，避免库存列表冗余。
*   **差值流转逻辑**: `RecipeInfoScreen` 具备计算能力，能实时提取食谱中的 `missedIngredients`。当用户点击“添加到购物车”时，该逻辑会自动将数据从食谱模型解构并构造为 `ShoppingItem` 写入 Firestore，实现模块间的功能穿透。

### 2.6. 技术依赖汇总 (Dependencies)
*   **核心开发**: Flutter SDK
*   **云服务**: `firebase_core`, `cloud_firestore`, `firebase_auth`
*   **网络通讯**: `http` (处理所有 Restful API 请求)
*   **硬件调用**: `camera`, `barcode_scan2`
*   **数据解析**: `csv`, `crypto` (处理百度 API 的 MD5 签名校验)

### 2.7. 界面架构 (Widget Architecture)

本节展示了应用中各页面的通用组件组织结构。采用这种组件框架旨在更好地适配不同尺寸的屏幕（手机与平板），并增强代码结构的可维护性与复用性。

#### 2.7.1. 跨设备适配策略
正如“用户界面 (3.)”章节所述，大部分平板端界面是由多个手机端页面并排组合而成的。为了实现这一设计，我们选择了以下组件框架：
*   **统一脚手架 (Scaffold)**：应用的主体结构包含一个在大多数页面中保持一致的顶部导航栏 (AppBar)。
*   **组件容器化 (Column-based Structure)**：页面主要内容被封装在一个 `Column` 布局中，该布局包含页面所需的所有核心组件。为了在平板模式下更好地复用，这些内容通常被包装在一个通用的 Widget 类中。

#### 2.7.2. 动态布局切换
手机端和平板端页面均被包裹在 **`LayoutBuilder`** 组件中。这使我们能够根据当前的屏幕尺寸动态地选择合适的布局设计，且这种切换过程对于页面的核心逻辑是完全透明的。

#### 2.7.3. 设计权衡
我们选择在页面级别（而非仅在单个小组件级别）进行响应式包装。这种做法的主要目的是在**代码复用性**与**设计灵活性**之间取得最佳平衡：
1.  **复用性**：核心功能逻辑（如食材列表、搜索控件）只需编写一次，即可同时出现在手机的独立页面和平板的侧边栏中。
2.  **灵活性**：允许针对不同屏幕比例调整交互细节（例如在平板上采用侧边导航，在手机上采用底部导航），而不会因过度耦合而限制视觉表现。

通过这种架构，NutriScan 能够在保持代码库简洁的同时，为不同形态的 Android 与 iOS 设备提供原生且高效的交互体验。

### 2.8. 核心业务流 (Business Sequence Flows)

#### 2.8.1. 智能录入时序
1. `HomeScreen` 调用相机 -> 获取图片。
2. 调用百度食材识别 -> 获取中文结果。
3. 调用百度翻译 -> 转换为标准化英文关键词。
4. 调用 Edamam API -> 获取营养系数。
5. 填充 UI 并提交 Firestore 存档。

#### 2.8.2. 库存匹配食谱时序
1. `InventoryScreen` 读取 Firestore 列表。
2. 用户选择 1-5 样待消耗食材 -> 跳转 `RecipeDetailScreen`。
3. 发送列表至 Spoonacular API -> 返回匹配度最高的食谱列表。
4. 在详情页同步比对购物车状态，高亮显示库存不足项。


---

## 3. 用户界面 (User Interface)

### 3.1. UI 设计选择 (UI Design Choices)

本应用旨在提供一个直观、高效的厨房资产管理环境。设计上采用了 Google 的 **Material 3** 规范，强调卡片式布局与层级清晰的视觉引导。

#### 3.1.1. 用户交互 (User Interaction)

- **多模式录入**: 提供手动文本、条形码扫描与 AI 图像识别三种路径，极大降低了食材录入的门槛。
- **即时反馈**: 在库存管理中使用“滑动删除”与“多选操作”，在录入时提供“自动补全”建议。
- **视觉状态提示**: 通过颜色编码呈现食材包时状态（如绿色代表新鲜，红色代表已过期）。

#### 3.1.2. 整体呈现 (Main Design)

- **季节性主题**: 应用内置了五套主题配色（春夏秋冬及默认），用户可以在设置中自由切换，使应用色调与现实季节保持同步。
- **卡片化布局**: 无论是食材卡片还是食谱卡片，均采用阴影与圆角设计，增强了界面的呼吸感与模块化程度。

### 3.2. 智能手机 UI (Smartphone UI)

#### 3.2.1. 登录与注册 (Login and Registration)

- **自动登录**: 通过 `AutoLoginSplash` 实现无缝的匿名/游客登录，让用户能够立即体验功能。
- **手动认证**: 提供基于 Firebase Auth 的注册与登录表单，支持用户同步云端数据。

#### 3.2.2. 首页与食材录入 (HomeScreen)

- 核心交互枢纽，包含三个录入入口。
- **实时营养看板**: 在输入食材名时，下方会根据 Edamam API 实时显示该食材的卡路里估算值。

#### 3.2.3. 库存管理页面 (InventoryScreen)

- **实时流列表**: 使用 `StreamBuilder` 挂载 Firestore 数据，展示当前冰箱内的所有食材。
- **快捷操作**: 支持批量清理过期食材及一键跳转到食谱查找。

#### 3.2.4. 食谱发现页面 (RecipeDetailScreen)

- **交互式过滤器**: 允许用户从现有库存中勾选需要消耗的食材。
- **缓存加载**: 显示“正在从本地加载”的提示条，优先展示 SharedPreferences 中的上次搜索结果。

#### 3.2.5. 食谱详情页面 (RecipeInfoScreen)

- **动态成分对比**: 将食谱所需与库存现状对比，列出“已有”与“缺失”两类清单。
- **多媒体集成**: 包含烹饪步骤、营养统计及 YouTube 视频链接跳转。

#### 3.2.6. 购物清单页面 (ShoppingCartScreen)

- 汇总所有待购物品，支持从食谱页一键注入缺失食材。
- 顶部内置“季节性推荐”入口，引导用户发现健康食材。

#### 3.2.7. 季节性推荐页面 (SeasonalListScreen)

- 基于本地逻辑展示当前季节最适宜采购的食材库。
- 支持搜索别名，并可点击加号图标直接将其同步至购物车。

#### 3.2.8. 个人中心与设置 (Profile & Settings)

- 管理用户头像、用户名及退出登录逻辑。
- **API 设置**: 允许用户在 Spoonacular (智能模式) 与 TheMealDB (免费模式) 之间切换食谱引擎。

### 3.3. 平板电脑 UI (Tablet UI)

#### 3.3.1. 响应式导航切换 (Navigation & Layout)

- **侧边导航栏 (NavigationRail)**: 在平板横屏或大屏模式下，底部的 TabBar 自动转化为侧边栏，优化了在大屏幕上的操作半径。
- **自适应布局**: 应用通过 `LayoutBuilder` 动态检测屏幕宽度，自动调整 Grid 布局的列数（从手机端的 2 列变为平板端的 4 列）。

#### 3.3.2. 主从视图设计 (Master-Detail View)

- **并排显示**: 在平板界面中，食谱列表（Master）与选中的食谱详情（Detail）会左右并排显示，减少了用户的返回次数，提升了在大屏设备上的信息密度和操作流畅度。
