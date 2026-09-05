# fnos-qnap8528-kmod

飞牛 fnOS 的 QNAP IT8528 EC 驱动 FPK 包。

将 [qnap8528](https://github.com/0xGiddi/qnap8528) 内核模块打包为飞牛应用中心可直接安装的 `.fpk` 格式，支持一键安装、卸载、启停管理。

## 功能

- 风扇控制 (PWM)
- 温度传感器读取
- LED 控制（电源、状态、USB 拷贝等）
- 前面板按键
- VPD 信息读取（机型、序列号、MAC 地址等）

## 支持机型

详见 [qnap8528 官方支持列表](https://github.com/0xGiddi/qnap8528#supported-models)。

> **注意**: TS-464、TS-664 等部分机型需要勾选「跳过硬件检测」才能正常加载。

## 安装要求

- fnOS 0.8.0+
- x86_64 架构
- 已安装当前内核的头文件：`linux-headers-$(uname -r)`

## 快速开始

### 1. 下载预编译 FPK

在 [Releases](https://github.com/YOUR_USERNAME/fnos-qnap8528-kmod/releases) 页面下载最新 `.fpk` 文件。

### 2. 手动打包

```bash
git clone https://github.com/YOUR_USERNAME/fnos-qnap8528-kmod.git
cd fnos-qnap8528-kmod
./build.sh
```

生成的 `qnap8528-kmod_1.24.0_x86.fpk` 可直接上传到飞牛应用中心安装。

### 3. 安装到飞牛

1. 打开飞牛「应用中心」
2. 点击「手动安装」，选择 `.fpk` 文件
3. 根据向导选择参数（如 `skip_hw_check`）
4. 等待 DKMS 编译完成

## 安装参数说明

| 参数 | 说明 | 适用机型 |
|------|------|---------|
| `skip_hw_check` | 跳过 VPD 硬件检测 | TS-464, TS-664 等 |
| `blink_sw_only` | 禁用硬件 LED 闪烁，改用软件模拟 | 通用 |
| `preserve_leds` | 加载驱动时不重置 LED 状态 | 通用 |

## 内核升级后的处理

由于驱动是 out-of-tree 模块，**内核升级后需要卸载并重新安装本应用**，DKMS 会自动重新编译。

应用会在状态检测中提示内核版本变化。

## 目录结构

```
.
├── manifest              # FPK 元信息
├── build.sh              # 打包容脚本
├── gen_icon.py           # 图标生成脚本
├── fnos/
│   ├── manifest          # 应用元数据
│   ├── config/           # privilege / resource
│   ├── cmd/
│   │   └── service-setup # 生命周期脚本 (install/start/stop/status)
│   ├── ui/               # 应用图标
│   ├── wizard/           # 安装向导
│   └── app/
│       └── qnap8528-src/ # qnap8528 驱动源码 (DKMS 编译用)
└── .github/workflows/    # CI 自动打包
```

## 致谢

- 驱动源码: [0xGiddi/qnap8528](https://github.com/0xGiddi/qnap8528)
- FPK 打包参考: [IamAyang233/fnos-i915-sriov-kmod](https://github.com/IamAyang233/fnos-i915-sriov-kmod)

## License

GPL-2.0 (与上游 qnap8528 保持一致)
