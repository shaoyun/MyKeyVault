# MyKeyVault

一个安全的TOTP认证器应用，支持生物识别认证保护您的数字身份。

## 功能特性

### 🔐 安全认证
- **生物识别认证**: 支持指纹识别和面部识别
- **密码备用认证**: 6位数字密码作为备用认证方式
- **会话管理**: 15分钟认证有效期，自动超时保护
- **失败保护**: 3次失败后自动锁定30秒

### 🛡️ 数据安全
- **本地加密存储**: 使用flutter_secure_storage安全存储
- **密码哈希**: 使用安全哈希算法保护密码
- **无云依赖**: 所有数据仅存储在本地设备

### 🎨 用户体验
- **Material Design 3**: 现代化的界面设计
- **深色/浅色主题**: 支持系统主题跟随
- **响应式布局**: 适配不同屏幕尺寸
- **首次使用引导**: 友好的设置向导

### ⚙️ 灵活配置
- **认证方式切换**: 在生物识别和密码间自由切换
- **超时时间设置**: 5分钟到1小时的灵活配置
- **主题选择**: 浅色、深色、跟随系统
- **安全设置**: 完整的认证配置选项

## 技术架构

### 核心技术栈
- **Flutter**: 跨平台移动应用框架
- **Provider**: 状态管理
- **local_auth**: 生物识别认证
- **flutter_secure_storage**: 安全存储
- **Material Design 3**: UI设计系统

### 项目结构
```
lib/
├── models/           # 数据模型
│   ├── auth_config.dart
│   ├── auth_error.dart
│   └── biometric_capability.dart
├── providers/        # 状态管理
│   └── auth_provider.dart
├── services/         # 业务逻辑
│   ├── auth_service.dart
│   └── secure_storage_service.dart
├── screens/          # 界面
│   ├── authentication_screen.dart
│   ├── onboarding_screen.dart
│   └── settings_screen.dart
├── widgets/          # 组件
│   ├── authentication_wrapper.dart
│   ├── biometric_auth_widget.dart
│   ├── password_auth_widget.dart
│   └── auth_config_widget.dart
└── utils/           # 工具类
    ├── auth_utils.dart
    ├── password_utils.dart
    └── performance_utils.dart
```

## 开始使用

### 环境要求
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android SDK >= 23 (Android 6.0)
- iOS >= 12.0

### 安装步骤

1. **克隆项目**
   ```bash
   git clone <repository-url>
   cd MyKeyVault
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **运行应用**
   ```bash
   flutter run
   ```

### 平台配置

#### Android配置
在 `android/app/src/main/AndroidManifest.xml` 中已配置必要权限：
```xml
<uses-permission android:name="android.permission.USE_FINGERPRINT" />
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
```

#### iOS配置
在 `ios/Runner/Info.plist` 中已配置Face ID使用说明：
```xml
<key>NSFaceIDUsageDescription</key>
<string>使用Face ID进行身份验证以保护您的TOTP密钥</string>
```

## 测试

### 运行测试
```bash
# 运行所有测试
flutter test

# 运行特定测试
flutter test test/providers/auth_provider_test.dart

# 运行测试并生成覆盖率报告
flutter test --coverage
```

### 测试覆盖
- **单元测试**: Provider、Service、Utils
- **Widget测试**: 所有UI组件
- **集成测试**: 完整认证流程
- **性能测试**: 启动和认证性能

## 性能优化

### 启动性能
- AuthProvider智能初始化，避免重复操作
- 生物识别能力检查缓存5分钟
- 异步加载非关键组件

### 内存管理
- 完善的资源清理机制
- 定时器自动清理
- 监听器生命周期管理

### UI性能
- 响应式布局适配小屏幕
- 平滑的过渡动画
- 60fps流畅体验

## 安全考虑

### 数据保护
- 密码使用安全哈希算法存储
- 配置信息加密存储
- 生物识别数据由系统管理，应用不直接访问

### 会话安全
- 15分钟自动超时
- 应用后台5分钟后需重新认证
- 锁屏后立即需要重新认证

### 错误处理
- 失败次数限制防止暴力破解
- 详细的错误日志用于调试
- 用户友好的错误提示

## 开发指南

### 代码规范
- 遵循Dart官方代码规范
- 使用有意义的变量和函数命名
- 完善的注释和文档

### 提交规范
- 使用语义化提交信息
- 每个功能独立提交
- 包含必要的测试用例

### 调试技巧
- 使用PerformanceUtils监控性能
- 启用Flutter Inspector调试UI
- 使用断点调试复杂逻辑

## 部署

### 构建发布版本
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

### 发布检查清单
- [ ] 所有测试通过
- [ ] 性能指标达标
- [ ] 真实设备测试
- [ ] 权限配置正确
- [ ] 版本号更新

## 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 更新日志

### v1.0.0 (2025-01-13)
- ✨ 新增生物识别认证功能
- ✨ 新增密码备用认证
- ✨ 新增会话管理
- ✨ 新增首次使用引导
- ✨ 新增设置页面
- 🎨 优化UI设计和用户体验
- ⚡ 性能优化和内存管理改进
- 🧪 完善测试覆盖

## 支持

如果您遇到问题或有建议，请：
- 查看 [FAQ](docs/FAQ.md)
- 提交 [Issue](issues)
- 联系开发团队

---

**MyKeyVault** - 保护您的数字身份，从认证开始 🔐
