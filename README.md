# Huawei Creator
***
Language:  
**English** | [简体中文](README_CN.md)  
***
## Usage


Generate ARM64 AB (Huawei device) from ARM64 AB and include patchs and optimisations (target image name is s-ab.img):

    sudo ./run-huawei-ab.sh systemAB.img "LeaOS" "ANE-LX1" "N"

Generate ARM64 AB (Huawei device) from ARM64 AB and include patchs and optimisations (target image name is s-vndklite.img ):

    sudo ./run-huawei-emui9-ab-a13.sh systemAB.img "LeaOS" "ANE-LX1" "Y" "N"
    
Generate ARM64 A-only (Huawei device) from ARM64 A-only and include patchs and optimisations (target image name is s-aonly.img):

    sudo ./run-huawei-aonly.sh systemAB.img "LeaOS" "PRA-LX1"

Generate ARM64 AB VNDKLite (Huawei device) from ARM64 AB and include patchs and optimisations (target image name is s-vndklite.img):

    sudo ./lite-adapter.sh 64 s-ab.img 
