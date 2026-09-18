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

## 7. [可選] Jupyter Notebook 版本控制設定（nbstripout）

`.ipynb` 檔案本身是 JSON，每次執行 cell 都會更動 `execution_count`（執行次數編號），即使程式碼完全沒改也會觸發無意義的 git diff，長期下來會讓 code review 和合併變得困難。本專案使用 `nbstripout`（已列於 `requirements.txt`）在 commit 時自動清除 `execution_count`，但保留每個 cell 的 output（分析結果、圖表等），確保實驗結果不會遺失。

### 7.0

直接清空 .ipynb 執行次數

```bash
nbstripout src/*.ipynb --keep-output
```

### 7.1 註冊 git filter

在專案根目錄執行，`--keep-output` 代表只清 `execution_count`，不清空 output：

```bash
nbstripout --install --keep-output --attributes .gitattributes
```

執行後 `.gitattributes` 應包含以下內容：

```
*.ipynb filter=nbstripout
*.ipynb diff=ipynb
```

### 7.2 確認設定是否正確帶入 --keep-output

`nbstripout --install` 在某些版本下不會把 `--keep-output` 參數寫進 git config，導致 output 仍被清空。安裝完務必檢查：

```bash
git config --get filter.nbstripout.clean
```

若輸出結尾**沒有**出現 `--keep-output`，需手動補上（將路徑換成本機的 `.venv` 位置）：

```bash
git config filter.nbstripout.clean '"D:/path/to/.venv/Scripts/python.exe" -m nbstripout --keep-output'
git config diff.ipynb.textconv '"D:/path/to/.venv/Scripts/python.exe" -m nbstripout -t --keep-output'
```

### 7.3 對已存在的 notebook 套用設定（renormalize）

若專案裡已有先前 commit 過的 notebook，需要重新套用 filter，讓舊的 `execution_count` 一併從 git 歷史清除：

```bash
git add --renormalize .
git status
```

若 `git status` 顯示 `nothing to commit`，代表本機檔案目前沒有 output 內容（可能之前被舊設定清空過）。此時需要重新執行 notebook 產生 output、存檔後再次 `git add .`，才會有內容被保留進 commit。

### 7.4 驗證 output 是否確實保留

```bash
git show :path/to/notebook.ipynb | grep -A5 '"outputs"'
```

若看到實際內容（而非空陣列 `[]`），代表設定正確，可以放心 commit。

### 7.5 如何把 execution_count 加回來（還原設定）

若之後不想再清除 `execution_count`（例如想追蹤 cell 實際執行順序），有兩種做法：

**做法一：完全移除 filter**（notebook 恢復原始行為，execution_count 與 output 都正常保留）：

```bash
nbstripout --uninstall
```

執行後會清除 `git config` 裡 `filter.nbstripout.*` 與 `diff.ipynb.*` 的設定。`.gitattributes` 裡的 `*.ipynb filter=nbstripout` 這幾行需自行刪除，否則 git 找不到對應 filter 會報錯。

**做法二：改用 --keep-count，只清 output、保留 execution_count**：

```bash
nbstripout --uninstall
nbstripout --install --keep-count --attributes .gitattributes
```

同樣要用 7.2 的方式檢查 `--keep-count` 有沒有被正確寫進 `git config`。

不管用哪種做法，改完設定後都要針對既有 notebook 重新套用一次，才能讓已經 commit 的檔案跟上新規則：

```bash
git add --renormalize .
git status
git commit -m "chore: restore execution_count in notebooks"
```

> 注意：新 clone 這個 repo 的人，需要各自在自己的環境重新執行第 7.1 步驟，`nbstripout --install`／`--uninstall` 是寫入本機 `.git/config`，不會隨 repo 一起同步給其他協作者。
