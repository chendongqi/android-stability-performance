# Demos - 问题复现示例

本目录包含各类Android稳定性和性能问题的复现Demo。

## 📂 目录说明

- **anr-demo/** - ANR场景复现（主线程阻塞、Binder超时、Input超时等）
- **crash-demo/** - Crash场景复现（Native Crash、JE、SIGABRT等）
- **performance-demo/** - 性能问题示例（启动慢、渲染卡顿、过度绘制）
- **memory-demo/** - 内存问题示例（OOM、内存泄漏、内存抖动）

## 🎯 使用方式

每个Demo都是独立的Android项目，可以直接编译运行：

```bash
cd <demo-name>
./gradlew installDebug
adb shell am start -n <package>/<activity>
```

## 📝 Demo特点

- ✅ 可编译运行，代码清晰注释
- ✅ 涵盖常见问题场景
- ✅ 配套专栏文章详细讲解
- ✅ 提供问题分析思路和解决方案

## 🚧 建设中

Demo代码正在持续完善，敬请期待！

