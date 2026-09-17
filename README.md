# 開發環境建置指南

本專案採用 Python 虛擬環境（venv）進行套件隔離，並配置支援 NVIDIA RTX 50 系列（Blackwell 架構）之 PyTorch 與 CUDA 13.2 執行環境。

---

## 1. 系統相依需求

- 作業系統：Windows 11 / 10、Linux 或 macOS
- Python 版本：Python 3.10 以上
- GPU 支援：NVIDIA GeForce RTX 50 系列（需安裝支援 CUDA 13.2+ 之最新版 NVIDIA 驅動程式）

---

## 2. 建立與啟動虛擬環境

請於專案根目錄執行以下指令建立 `.venv` 虛擬環境：

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

> 啟動成功後，終端機提示字元前方將顯示 `(.venv)` 標記。

---

## 3. 升級套件管理工具

在安裝任何相依套件前，必須先將 `pip` 升級至最新版本。

在 Windows 系統中，請務必使用 `python -m pip` 指令執行升級，以避免執行中的 `pip.exe` 檔案被系統鎖定導致更新失敗：

```bash
python -m pip install --upgrade pip

```

---

## 4. 安裝專案相依套件

專案所需的相依套件已記錄於 `requirements.txt`。該檔案開頭已指定 PyTorch CUDA 13.2 的官方來源索引：

```bash
python -m pip install -r requirements.txt

```

---

## 5. 註冊 Jupyter Kernel

為使 VS Code 或 JupyterLab 能正確識別並掛載虛擬環境，需將環境註冊至系統清單：

```bash
python -m ipykernel install --user --name nchu_dl --display-name "Python (nchu-dl)"

```

### VS Code 設定步驟

1. 於 VS Code 中開啟專案內的 `.ipynb` 筆記本檔案。
2. 點選視窗右上角的「選取核心（Select Kernel）」。
3. 選擇「Jupyter Kernel...」，並選取清單中的 `Python (nchu-dl)`。
4. 若清單未出現，請選擇「Python Environments...」並手動指定路徑至專案目錄下的 `.venv/Scripts/python.exe`。

---

## 6. 環境與硬體驗證

請在已啟動環境的終端機執行以下指令，驗證直譯器路徑、PyTorch 版本與 GPU 硬體加速狀態：

```bash
python -c "import sys, torch; print('Python 直譯器:', sys.executable); print('PyTorch 版本:', torch.__version__); print('CUDA 可用性:', torch.cuda.is_available()); print('GPU 裝置:', torch.cuda.get_device_name(0) if torch.cuda.is_available() else '無 GPU'); print('算力架構:', torch.cuda.get_device_capability(0) if torch.cuda.is_available() else 'N/A')"

```

預期正確輸出指標：

- 直譯器路徑必須包含 `.venv`。
- `CUDA 可用性` 需為 `True`。
- `算力架構` 若為 RTX 50 系列，需顯示為 `(12, 0)`。

---

## 7. 版本控制注意事項

實體虛擬環境目錄（`.venv/`）包含平台專屬二進位執行檔且體積龐大，**嚴禁提交至 Git 儲存庫**。

請確認專案根目錄的 `.gitignore` 檔案已包含以下設定：

```gitignore
.venv/
__pycache__/
*.pyc
.ipynb_checkpoints/

```
