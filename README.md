# Usage


Generate ARM64 AB (Huawei device) from ARM64 AB and include patchs and optimisations (target image name is s-ab.img):

    sudo ./run-huawei-ab.sh systemAB.img "LeaOS" "ANE-LX1"

Generate ARM64 A-only (Huawei device) from ARM64 A-only and include patchs and optimisations (target image name is s-aonly.img):

    sudo ./run-huawei-aonly.sh systemAB.img "LeaOS" "PRA-LX1"

Generate ARM64 AB VNDKLite (Huawei device) from ARM64 AB and include patchs and optimisations (target image name is s-vndklite.img):

    sudo ./run-huawei-ab.sh systemAB.img "LeaOS" "ANE-LX1"
