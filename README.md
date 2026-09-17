# 開發環境建置指南

本專案使用 Python 虛擬環境（venv）隔離套件，並配置支援 NVIDIA RTX 50 系列（Blackwell 架構）的 PyTorch 與 CUDA 13.2 環境。

---

## 1. 系統需求

- 作業系統：Windows 11 / 10、Linux 或 macOS
- Python 版本：Python 3.10 以上
- GPU 支援：NVIDIA GeForce RTX 50 系列（需安裝支援 CUDA 13.2+ 的最新版 NVIDIA 驅動程式）

---

## 2. 建立與啟動虛擬環境

在專案根目錄執行以下指令建立 `.venv` 虛擬環境：

```bash
# 建立虛擬環境
python -m venv .venv
```

依作業系統與終端機類型啟動虛擬環境：

- **Windows (Git Bash)**：

```bash
source .venv/Scripts/activate

```

- **Windows (PowerShell)**：

```powershell
.\.venv\Scripts\Activate.ps1

```

- **Linux / macOS**：

```bash
source .venv/bin/activate

```

> 啟動成功後，終端機提示字元前會出現 `(.venv)` 標記。

---

## 3. 升級套件管理工具

在安裝任何相依套件前，必須先將 `pip` 升級至最新版本。

在 Windows 系統中，請務必使用 `python -m pip` 升級，避免執行中的 `pip.exe` 被系統鎖定而更新失敗：

```bash
python -m pip install --upgrade pip

```

---

## 4. 安裝專案相依套件

專案相依套件記錄在 `requirements.txt`，檔頭已指定 PyTorch CUDA 13.2 的官方來源索引：

```bash
python -m pip install -r requirements.txt

```

---

## 5. 註冊 Jupyter Kernel

為了讓 VS Code 或 JupyterLab 能正確辨識並使用這個虛擬環境，需將環境註冊至 Jupyter 核心清單：

```bash
python -m ipykernel install --user --name nchu_dl --display-name "Python (nchu-dl)"

```

### VS Code 設定步驟

1. 在 VS Code 中開啟專案內的 `.ipynb` 筆記本。
2. 點選視窗右上角的「選取核心（Select Kernel）」。
3. 選擇「Jupyter Kernel...」，並選取清單中的 `Python (nchu-dl)`。
4. 如果清單沒出現，請選「Python Environments...」，並手動指向專案目錄下的 `.venv/Scripts/python.exe`。

---

## 6. 環境與硬體驗證

請在已啟動環境的終端機執行以下指令，驗證直譯器路徑、PyTorch 版本與 GPU 硬體加速狀態：

```bash
python -c "import sys, torch; print('Python 直譯器:', sys.executable); print('PyTorch 版本:', torch.__version__); print('CUDA 可用性:', torch.cuda.is_available()); print('GPU 裝置:', torch.cuda.get_device_name(0) if torch.cuda.is_available() else '無 GPU'); print('算力架構:', torch.cuda.get_device_capability(0) if torch.cuda.is_available() else 'N/A')"

```

預期輸出結果：

- 直譯器路徑必須包含 `.venv`。
- `CUDA 可用性` 應為 `True`。
- `算力架構` 若為 RTX 50 系列，需顯示為 `(12, 0)`。

---
