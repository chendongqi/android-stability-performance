#!/bin/bash
# collect_all_logs.sh - 一键收集所有异常日志

set -e

# 配置
OUTPUT_DIR="./logs_$(date +%Y%m%d_%H%M%S)"
PACKAGE_NAME=$1  # 可选:指定包名

echo "================================"
echo "Android异常日志收集工具"
echo "================================"
echo "输出目录: $OUTPUT_DIR"
echo ""

# 创建输出目录
mkdir -p $OUTPUT_DIR

# 1. 收集Logcat
echo "[1/6] 收集Logcat日志..."
adb logcat -d -v threadtime > $OUTPUT_DIR/logcat.txt
adb logcat -b system -d -v threadtime > $OUTPUT_DIR/logcat_system.txt
adb logcat -b events -d -v threadtime > $OUTPUT_DIR/logcat_events.txt
adb logcat -b crash -d -v threadtime > $OUTPUT_DIR/logcat_crash.txt
echo "  ✓ Logcat日志已保存"

# 2. 收集DropBox
echo "[2/6] 收集DropBox日志..."
adb shell dumpsys dropbox > $OUTPUT_DIR/dropbox_list.txt
adb shell dumpsys dropbox --print anr > $OUTPUT_DIR/dropbox_anr.txt 2>/dev/null || echo "No ANR logs"
adb shell dumpsys dropbox --print data_app_crash > $OUTPUT_DIR/dropbox_crash.txt 2>/dev/null || echo "No crash logs"
adb shell dumpsys dropbox --print system_server_watchdog > $OUTPUT_DIR/dropbox_watchdog.txt 2>/dev/null || echo "No watchdog logs"
echo "  ✓ DropBox日志已保存"

# 3. 收集Tombstones
echo "[3/6] 收集Tombstone日志..."
adb root 2>/dev/null && sleep 2
mkdir -p $OUTPUT_DIR/tombstones
adb pull /data/tombstones/ $OUTPUT_DIR/tombstones/ 2>/dev/null || echo "  ! 无法获取Tombstone(可能需要root)"

# 4. 收集ANR traces (Android 10-)
echo "[4/6] 收集ANR traces..."
adb pull /data/anr/ $OUTPUT_DIR/anr/ 2>/dev/null || echo "  ! 无ANR traces文件(Android 11+在DropBox中)"

# 5. 收集系统信息
echo "[5/6] 收集系统信息..."
adb shell dumpsys meminfo > $OUTPUT_DIR/meminfo.txt
adb shell dumpsys cpuinfo > $OUTPUT_DIR/cpuinfo.txt
adb shell dumpsys battery > $OUTPUT_DIR/battery.txt
adb shell ps -A > $OUTPUT_DIR/processes.txt
adb shell getprop > $OUTPUT_DIR/properties.txt

# 6. 如果指定了包名,收集应用信息
if [ -n "$PACKAGE_NAME" ]; then
    echo "[6/6] 收集应用信息 ($PACKAGE_NAME)..."
    adb shell dumpsys package $PACKAGE_NAME > $OUTPUT_DIR/package_info.txt 2>/dev/null || echo "  ! 包名不存在"
    adb shell dumpsys activity $PACKAGE_NAME > $OUTPUT_DIR/activity_info.txt 2>/dev/null
else
    echo "[6/6] 跳过应用信息收集(未指定包名)"
fi

# 生成摘要报告
echo ""
echo "生成摘要报告..."
cat > $OUTPUT_DIR/README.txt << EOF
Android异常日志收集报告
======================

收集时间: $(date)
设备信息: $(adb shell getprop ro.product.model) ($(adb shell getprop ro.build.version.release))
包名: ${PACKAGE_NAME:-未指定}

目录结构:
├── logcat*.txt          - Logcat日志
├── dropbox_*.txt        - DropBox异常日志
├── tombstones/          - Native崩溃详情
├── anr/                 - ANR traces文件
├── meminfo.txt          - 内存信息
├── cpuinfo.txt          - CPU使用情况
├── battery.txt          - 电量信息
├── processes.txt        - 进程列表
├── properties.txt       - 系统属性
└── package_info.txt     - 应用信息(如果指定)

分析建议:
1. 优先查看 dropbox_anr.txt 和 dropbox_crash.txt
2. 如有Native崩溃,查看 tombstones/ 目录
3. 结合 logcat.txt 查看完整事件时间线
4. 检查 meminfo.txt 和 cpuinfo.txt 了解资源使用情况

EOF

echo ""
echo "================================"
echo "✓ 日志收集完成!"
echo "================================"
echo "输出目录: $OUTPUT_DIR"
echo "文件数量: $(ls -1 $OUTPUT_DIR | wc -l)"
echo "总大小: $(du -sh $OUTPUT_DIR | cut -f1)"
echo ""
echo "使用方法:"
echo "  查看摘要: cat $OUTPUT_DIR/README.txt"
echo "  压缩打包: tar -czf ${OUTPUT_DIR}.tar.gz $OUTPUT_DIR"
echo ""
