# FreshBasket 
### 智能全场景食材管理系统 

---

## 技术架构
- **云端服务**: 集成 Firebase (Authentication, Firestore, Cloud Messaging)。
- **数据持久化**: 结合本地存储与云端同步，支持离线访问。
- **响应式适配**: 针对平板电脑优化，采用 Master-Detail 模式与 NavigationRail 布局。

## 外部服务集成
1.  **Google Gemini API**: 驱动对话式生成 AI 厨房助手。
2.  **Edamam API**: 获取食材详细营养信息（卡路里等）。
3.  **OpenFoodFacts API**: 通过条形码精准获取全球食品信息。
4.  **Baidu APIs**: 提供基于图像的物体识别与多语言输出翻译。
5.  **Spoonacular & TheMealDB**: 双重路由的菜谱搜索与烹饪指导引擎。

## 核心功能展示
- **多模态登录**: 支持邮箱、Google 账号及匿名游客访问。
<img width="300" alt="图片" src="https://github.com/user-attachments/assets/fb868ce0-7ee0-488b-8324-133e2bab4069" />

- **智能入库**: 手动输入、条码扫描、拍照识别三合一。
<img width="300" alt="图片" src="https://github.com/user-attachments/assets/8e30ebba-ded2-4cf0-aa22-dc58f1d3c573" />

- **动态库存管理**: 实时显示食材状态，自动发送过期提醒通知。
<img width="300" alt="图片" src="https://github.com/user-attachments/assets/393f39e0-7606-4c92-a235-ddf2ada9840a" />

- **食谱搜索**: 支持两种API，获取全方面的食谱信息，并提供内容缓存。
<img width="300" alt="图片" src="https://github.com/user-attachments/assets/467ebd80-f1a5-4898-bae4-9746bf056be2" />

- **AI 助手**: 内置 Gemini 引擎，根据当前库存提供个性化烹饪建议。
<img width="300" alt="图片" src="https://github.com/user-attachments/assets/96d981df-f591-4bfa-a20b-f1f5b1dccab5" />

- **购物车**：可以通过多种方式调整购物车内容。
<img width="300" alt="图片" src="https://github.com/user-attachments/assets/2f7e867e-bd18-48af-a41e-2b899843155c" />



## 质量保障
- **单元测试 (Unit Test)**: **135** 个测试用例，覆盖核心逻辑与数据转换。
- **组件测试 (Widget Test)**: **120** 个测试用例，确保 UI 组件在各种状态下的渲染正确。
- **集成测试 (Integration Test)**: 覆盖关键用户路径，确保端到端流程。
- **测试环境**: 完整实现了 Mock 环境与真机部署环境的切换。
