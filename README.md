# Huawei GSI镜像优化/转化脚本  
用于把[phh GSI](https://github.com/phhusson/treble_experimentations/wiki/Generic-System-Image-%28GSI%29-list)的GSI镜像转化为带有华为优化补丁的版本。  
***
## 使用  

1. 先安装xattr : `sudo apt install xattr`
2. 使用什么脚本取决于你想转换什么版本的GSI镜像。如:**AB分区**镜像用**run-huawei-ab.sh**(Android 13的用**run-huawei-ab-a13.sh**)。**A-Only分区**用**run-huawei-aonly.sh**。以此类推。
3. 命令语法是 : `sudo bash xxxx.sh xxxx.img "GSI镜像名称" "设备型号代码" "是否开启华为原生开机动画，只能选择Y或者N"`。xxxx.sh是你选择的脚本，xxxx.img是你选择的GSI镜像。剩下的在命令里展现了。举个详细例子: `sudo bash run-huawei-ab-a13.sh PixelExperience_Plus_arm64-ab-13.0-20230421-UNOFFICIAL.img "PixelExperience Plus 13.0" "VTR-L09" "N"` 。

   
***
## 原始README
Generate ARM64 AB (Huawei device) from ARM64 AB and include patchs and optimisations (target image name is s-ab.img):

    sudo ./run-huawei-ab.sh systemAB.img "LeaOS" "ANE-LX1"

Generate ARM64 A-only (Huawei device) from ARM64 A-only and include patchs and optimisations (target image name is s-aonly.img):

    sudo ./run-huawei-aonly.sh systemAB.img "LeaOS" "PRA-LX1"

Generate ARM64 AB VNDKLite (Huawei device) from ARM64 AB and include patchs and optimisations (target image name is s-vndklite.img):

    sudo ./lite-adapter.sh 64 s-ab.img 

# 创始人
@Iceows ： [Github](https://github.com/Iceows)

## 自用修改
@Coconutat