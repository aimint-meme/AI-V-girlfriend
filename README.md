# 🤖 AI Virtual Girlfriend - 智能虚拟女友应用

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-43853D?style=for-the-badge&logo=node.js&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB-4EA94B?style=for-the-badge&logo=mongodb&logoColor=white)
![OpenAI](https://img.shields.io/badge/OpenAI-412991?style=for-the-badge&logo=openai&logoColor=white)

*一个基于AI技术的智能虚拟女友应用，提供个性化对话、情感陪伴和智能交互体验*

[功能特性](#-功能特性) • [技术栈](#-技术栈) • [快速开始](#-快速开始) • [开发指南](#-开发指南) • [API文档](#-api文档)

</div>

---

## 📖 项目介绍

**AI Virtual Girlfriend** 是一款创新的人工智能虚拟女友应用，旨在为用户提供个性化的情感陪伴和智能对话体验。该项目结合了最新的AI技术、自然语言处理和情感计算，创造出能够理解用户情感、提供贴心陪伴的虚拟角色。

### 🎯 项目愿景

- **情感陪伴**：为用户提供24/7的情感支持和陪伴
- **个性化体验**：基于用户偏好和互动历史，提供定制化的对话体验
- **智能交互**：利用先进的AI技术，实现自然流畅的对话交流
- **多元化功能**：集成语音、文字、图片等多种交互方式

---

## ✨ 功能特性

### 🗣️ 智能对话系统
- **自然语言处理**：基于GPT模型的智能对话引擎
- **情感识别**：实时分析用户情感状态，提供相应回应
- **上下文记忆**：保持对话连贯性，记住用户偏好和历史
- **多轮对话**：支持复杂的多轮对话场景

### 👤 个性化角色定制
- **角色创建**：自定义虚拟女友的外观、性格和背景
- **性格配置**：多维度性格设定（温柔、活泼、知性等）
- **能力配置**：定制角色的专业技能和兴趣爱好
- **互动模式**：多种互动模式（聊天、学习、娱乐等）

### 🎵 多媒体交互
- **语音对话**：支持语音输入和语音回复
- **图片分享**：图片识别和描述功能
- **表情互动**：丰富的表情和动作表达
- **场景模拟**：多种对话场景和背景设置

### 📊 数据分析与管理
- **对话分析**：对话内容和情感倾向统计
- **用户行为**：用户活跃度和偏好分析
- **内容管理**：语音库、场景库、知识库管理
- **系统监控**：实时性能监控和日志管理

### 💎 会员与付费系统
- **会员等级**：多层级会员体系
- **虚拟货币**：金币系统和充值功能
- **付费服务**：高级功能和专属内容
- **订阅管理**：灵活的订阅和续费机制

---

## 🛠️ 技术栈

### 前端技术

| 技术 | 版本 | 用途 |
|------|------|------|
| **Flutter** | 3.32.8 | 跨平台移动应用开发框架 |
| **Dart** | 3.0+ | Flutter应用开发语言 |
| **Provider** | ^6.0.0 | 状态管理解决方案 |
| **Go Router** | ^10.0.0 | 路由管理 |
| **HTTP** | ^1.1.0 | 网络请求库 |

### 后端技术

| 技术 | 版本 | 用途 |
|------|------|------|
| **Node.js** | 18.0+ | 服务器运行环境 |
| **Express.js** | ^4.18.0 | Web应用框架 |
| **MongoDB** | 6.0+ | NoSQL数据库 |
| **Mongoose** | ^7.0.0 | MongoDB对象建模工具 |
| **Socket.io** | ^4.7.0 | 实时通信 |
| **JWT** | ^9.0.0 | 身份验证 |

### AI与机器学习

| 技术 | 用途 |
|------|------|
| **OpenAI GPT-4** | 自然语言生成和理解 |
| **Azure Cognitive Services** | 语音识别和合成 |
| **TensorFlow.js** | 客户端机器学习 |
| **Sentiment Analysis** | 情感分析 |

### 开发工具

| 工具 | 用途 |
|------|------|
| **Docker** | 容器化部署 |
| **Git** | 版本控制 |
| **VS Code** | 集成开发环境 |
| **Postman** | API测试 |
| **MongoDB Compass** | 数据库管理 |

---

## 🚀 快速开始

### 📋 系统要求

- **操作系统**：Windows 10+, macOS 10.14+, Linux
- **Flutter SDK**：3.32.8 或更高版本
- **Node.js**：18.0 或更高版本
- **MongoDB**：6.0 或更高版本
- **内存**：至少 8GB RAM
- **存储**：至少 10GB 可用空间

### 📥 安装步骤

#### 1. 克隆项目

```bash
git clone https://github.com/your-username/ai-virtual-girlfriend.git
cd ai-virtual-girlfriend
```

#### 2. 后端设置

```bash
# 进入后端目录
cd ai_girlfriend_backend

# 安装依赖
npm install

# 复制环境配置文件
cp .env.example .env

# 编辑环境变量
nano .env
```

**环境变量配置** (`.env`)：
```env
# 数据库配置
MONGODB_URI=mongodb://localhost:27017/ai_girlfriend

# JWT密钥
JWT_SECRET=your-super-secret-jwt-key

# OpenAI API配置
OPENAI_API_KEY=your-openai-api-key
OPENAI_MODEL=gpt-4

# 服务器配置
PORT=3000
NODE_ENV=development

# Azure认知服务（可选）
AZURE_SPEECH_KEY=your-azure-speech-key
AZURE_SPEECH_REGION=your-region
```

#### 3. 启动后端服务

```bash
# 开发模式
npm run dev

# 生产模式
npm start
```

#### 4. 前端应用设置

```bash
# 返回项目根目录
cd ..

# 获取Flutter依赖
flutter pub get

# 运行移动应用
flutter run
```

#### 5. 管理后台设置

```bash
# 进入管理后台目录
cd ai_girlfriend_admin

# 获取依赖
flutter pub get

# 运行管理后台（Web版）
flutter run -d chrome
```

### 🐳 Docker 部署

```bash
# 构建并启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

---

## 🔧 开发环境配置

### Flutter 开发环境

#### 1. 安装 Flutter SDK

```bash
# Windows (使用 Chocolatey)
choco install flutter

# macOS (使用 Homebrew)
brew install --cask flutter

# Linux
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.32.8-stable.tar.xz
tar xf flutter_linux_3.32.8-stable.tar.xz
export PATH="$PATH:`pwd`/flutter/bin"
```

#### 2. 验证安装

```bash
flutter doctor
```

#### 3. 配置编辑器

**VS Code 插件**：
- Flutter
- Dart
- Flutter Widget Snippets
- Awesome Flutter Snippets

**Android Studio 插件**：
- Flutter
- Dart

### Node.js 开发环境

#### 1. 安装 Node.js

```bash
# 使用 nvm (推荐)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 18
nvm use 18

# 或直接下载安装
# https://nodejs.org/
```

#### 2. 全局工具安装

```bash
npm install -g nodemon
npm install -g pm2
npm install -g @nestjs/cli
```

### 数据库配置

#### MongoDB 安装

```bash
# Ubuntu/Debian
sudo apt-get install mongodb

# macOS
brew install mongodb-community

# Windows
# 下载并安装 MongoDB Community Server
# https://www.mongodb.com/try/download/community
```

#### 数据库初始化

```bash
# 启动 MongoDB
sudo systemctl start mongod

# 连接数据库
mongo

# 创建数据库和用户
use ai_girlfriend
db.createUser({
  user: "ai_girlfriend_user",
  pwd: "your_password",
  roles: ["readWrite"]
})
```

### 开发工具配置

#### Git 配置

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global init.defaultBranch main
```

#### 代码格式化

**Flutter/Dart**：
```bash
# 格式化代码
dart format .

# 分析代码
dart analyze
```

**Node.js**：
```bash
# 安装 ESLint 和 Prettier
npm install -g eslint prettier

# 格式化代码
prettier --write .

# 代码检查
eslint .
```

---

## 📁 项目结构

```
ai-virtual-girlfriend/
├── 📱 lib/                          # Flutter 移动应用
│   ├── models/                      # 数据模型
│   ├── providers/                   # 状态管理
│   ├── screens/                     # 页面组件
│   ├── services/                    # 业务服务
│   ├── utils/                       # 工具函数
│   └── widgets/                     # UI组件
├── 🖥️ ai_girlfriend_admin/          # Flutter Web 管理后台
│   ├── lib/
│   │   ├── constants/               # 常量定义
│   │   ├── models/                  # 数据模型
│   │   ├── providers/               # 状态管理
│   │   ├── screens/                 # 管理页面
│   │   ├── services/                # 业务服务
│   │   └── widgets/                 # UI组件
│   └── web/                         # Web资源
├── 🔧 ai_girlfriend_backend/        # Node.js 后端服务
│   ├── src/
│   │   ├── controllers/             # 控制器
│   │   ├── middleware/              # 中间件
│   │   ├── models/                  # 数据模型
│   │   ├── routes/                  # 路由定义
│   │   ├── services/                # 业务服务
│   │   └── utils/                   # 工具函数
│   ├── config/                      # 配置文件
│   └── server.js                    # 服务器入口
├── 🎨 assets/                       # 静态资源
│   ├── icons/                       # 图标文件
│   └── images/                      # 图片资源
├── 🐳 docker-compose.yml            # Docker编排文件
├── 📋 README.md                     # 项目说明
└── 🚫 .gitignore                    # Git忽略规则
```

---

## 📚 API文档

### 🔗 API 端点概览

| 模块 | 端点 | 描述 |
|------|------|------|
| **认证** | `/api/auth/*` | 用户认证相关接口 |
| **用户** | `/api/users/*` | 用户管理接口 |
| **角色** | `/api/characters/*` | 虚拟角色管理 |
| **对话** | `/api/chat/*` | 对话交互接口 |
| **内容** | `/api/content/*` | 内容管理接口 |
| **支付** | `/api/payments/*` | 支付相关接口 |
| **分析** | `/api/analytics/*` | 数据分析接口 |

### 🔐 认证接口

#### 用户注册
```http
POST /api/auth/register
Content-Type: application/json

{
  "username": "user123",
  "email": "user@example.com",
  "password": "securePassword123"
}
```

#### 用户登录
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "securePassword123"
}
```

### 💬 对话接口

#### 发送消息
```http
POST /api/chat/message
Authorization: Bearer <token>
Content-Type: application/json

{
  "characterId": "char_123",
  "message": "你好，今天天气怎么样？",
  "type": "text"
}
```

#### 获取对话历史
```http
GET /api/chat/history?characterId=char_123&limit=50&offset=0
Authorization: Bearer <token>
```

### 👤 角色管理接口

#### 创建角色
```http
POST /api/characters
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "小雪",
  "personality": "温柔体贴",
  "avatar": "https://example.com/avatar.jpg",
  "background": "大学生，喜欢阅读和音乐"
}
```

#### 获取角色列表
```http
GET /api/characters?page=1&limit=10
Authorization: Bearer <token>
```

### 📊 响应格式

#### 成功响应
```json
{
  "success": true,
  "data": {
    "id": "123",
    "message": "操作成功"
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

#### 错误响应
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "请求参数不正确",
    "details": {
      "field": "email",
      "issue": "邮箱格式不正确"
    }
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### 📖 详细API文档

- **Swagger UI**: [http://localhost:3000/api-docs](http://localhost:3000/api-docs)
- **Postman Collection**: [下载链接](./docs/api/postman_collection.json)
- **API参考文档**: [查看详细文档](./docs/api/README.md)

---

## 🧪 测试

### 单元测试

```bash
# Flutter 测试
flutter test

# Node.js 测试
cd ai_girlfriend_backend
npm test
```

### 集成测试

```bash
# Flutter 集成测试
flutter drive --target=test_driver/app.dart

# API 集成测试
cd ai_girlfriend_backend
npm run test:integration
```

### 性能测试

```bash
# 使用 Artillery 进行负载测试
npm install -g artillery
artillery run test/load-test.yml
```

---

## 🚀 部署

### 生产环境部署

#### 1. 服务器要求
- **CPU**: 4核心以上
- **内存**: 16GB以上
- **存储**: 100GB SSD
- **网络**: 100Mbps带宽

#### 2. Docker 部署

```bash
# 生产环境构建
docker-compose -f docker-compose.prod.yml up -d

# 监控服务状态
docker-compose -f docker-compose.prod.yml ps
```

#### 3. 传统部署

```bash
# 后端部署
cd ai_girlfriend_backend
npm run build
pm2 start ecosystem.config.js

# 前端构建
flutter build apk --release
flutter build web --release
```

### CI/CD 配置

参考 `.github/workflows/` 目录下的GitHub Actions配置文件。

---

## 📈 监控与日志

### 应用监控
- **性能监控**: New Relic / DataDog
- **错误追踪**: Sentry
- **日志管理**: ELK Stack

### 健康检查
```bash
# 后端健康检查
curl http://localhost:3000/health

# 数据库连接检查
curl http://localhost:3000/health/db
```

---

## 🤝 贡献指南

### 开发流程

1. **Fork 项目**
2. **创建功能分支**: `git checkout -b feature/amazing-feature`
3. **提交更改**: `git commit -m 'Add some amazing feature'`
4. **推送分支**: `git push origin feature/amazing-feature`
5. **创建 Pull Request**

### 代码规范

- **Flutter**: 遵循 [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- **Node.js**: 遵循 [Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript)
- **提交信息**: 遵循 [Conventional Commits](https://www.conventionalcommits.org/)

### 问题报告

请使用 [GitHub Issues](https://github.com/your-username/ai-virtual-girlfriend/issues) 报告问题，包含：
- 问题描述
- 复现步骤
- 期望行为
- 系统环境
- 相关截图

---

## 📄 许可证

本项目采用 [MIT License](LICENSE) 许可证。

---

## 👥 团队

- **项目负责人**: [Your Name](https://github.com/your-username)
- **前端开发**: [Frontend Dev](https://github.com/frontend-dev)
- **后端开发**: [Backend Dev](https://github.com/backend-dev)
- **AI工程师**: [AI Engineer](https://github.com/ai-engineer)

---

## 📞 联系我们

- **邮箱**: contact@ai-virtual-girlfriend.com
- **官网**: https://ai-virtual-girlfriend.com
- **Discord**: [加入我们的社区](https://discord.gg/ai-virtual-girlfriend)
- **微信群**: 扫描二维码加入

---

## 🙏 致谢

感谢以下开源项目和服务：

- [Flutter](https://flutter.dev/) - 跨平台UI框架
- [Node.js](https://nodejs.org/) - JavaScript运行时
- [MongoDB](https://www.mongodb.com/) - 文档数据库
- [OpenAI](https://openai.com/) - AI语言模型
- [所有贡献者](https://github.com/your-username/ai-virtual-girlfriend/contributors)

---

<div align="center">

**⭐ 如果这个项目对你有帮助，请给我们一个星标！**

[⬆ 回到顶部](#-ai-virtual-girlfriend---智能虚拟女友应用)

</div>
