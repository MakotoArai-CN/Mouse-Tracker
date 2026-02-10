<div align="center">

<div>

<img src="./doc/icon.png" width="256" height="256" alt="Mouse Tracker Logo" />
</br>
<h1 align="center">Mouse Tracker</h1>
</br>
Zig言語で開発されたモダンなWindowsデスクトップ向けマウス座標リアルタイム追跡アプリケーション。極限まで軽量、高速動作を実現。

</div>
</div>

## 機能一覧

### リアルタイム座標追跡 📍

- 高リフレッシュレートでマウスX/Y座標を表示
- スクリーン解像度に対する割合表示
- 移動軌跡の可視化チャート
- X/Y座標プログレスバー

### システムトレイ統合 🎯

- ウィンドウを閉じると自動的にシステムトレイに最小化
- トレイアイコン右クリックメニュー：表示/非表示、ロック/ロック解除、追従/固定、概要、終了
- トレイアイコンをダブルクリックでウィンドウ表示を切り替え

### クリップボードコピー 📋

- **Space** キーで座標をロックし、自動的にクリップボードにコピー
- **C** キーでいつでも現在の座標をコピー
- コピー形式：`X, Y`（例：`1920, 1080`）
- コピー成功/失敗を色で表示

### コンパクトUIモード 🔽

- **Ctrl+M** でコンパクト/フル表示を切り替え
- コンパクトモードではX/Y座標のみ表示、ウィンドウサイズが大幅に縮小
- フルモードと同じレイアウトを維持

### ウィンドウ追従 🖱️

- **F** キーで追従/固定モードを切り替え
- 追従モードではウィンドウがマウスに自動追従
- スマート境界検出でウィンドウが画面外に出ない
- トレイメニューからも切り替え可能

### グローバルホットキー ⌨️

- **Ctrl+H** グローバルホットキーでウィンドウの表示/非表示を切り替え（どのアプリからでも使用可能）

## キーボードショートカット

| ショートカット | 機能 |
|---------------|------|
| **Space** | 座標のロック/ロック解除（ロック時に自動コピー） |
| **C** | 現在の座標をクリップボードにコピー |
| **Ctrl+M** | コンパクト/フルUIモードの切り替え |
| **F** | ウィンドウ追従/固定モードの切り替え |
| **Ctrl+H** | グローバルでウィンドウの表示/非表示を切り替え |

## トレイメニュー

| メニュー項目 | 機能 |
|-------------|------|
| 表示/非表示 | ウィンドウの可視性を切り替え |
| ロック/ロック解除 | 座標ロック状態を切り替え |
| 追従/固定 | ウィンドウ追従モードを切り替え |
| 概要(GitHub) | プロジェクトのGitHubページを開く |
| 終了 | アプリケーションを完全に終了 |

## ビルドと実行

### 動作環境

- Zig 0.14.x
- Windows 10/11

### コンパイル

```bash
# Zigバージョンの確認
zig version

# デバッグビルド
zig build

# リリースビルド（サイズ最適化）
zig build release

# ビルドして実行
zig build run
```

### マルチアーキテクチャ対応

```bash
# 64ビット Windows（デフォルト）
zig build

# 32ビット Windows
zig build -Dtarget=x86-windows

# ARM64 Windows
zig build -Dtarget=aarch64-windows
```

### 実行

```bash
# ビルド後に直接実行
zig build run

# または手動で実行
./zig-out/bin/mouse-tracker.exe
```

## アイコン設定

アイコンファイルを `resources/icon.ico` に配置してください。PNGファイルのみの場合は以下の方法で変換できます：

```powershell
# PowerShellで変換
Add-Type -AssemblyName System.Drawing
$bmp = [System.Drawing.Bitmap]::FromFile("$PWD\resources\icon.png")
$icon = [System.Drawing.Icon]::FromHandle($bmp.GetHicon())
$stream = [System.IO.File]::Create("$PWD\resources\icon.ico")
$icon.Save($stream)
$stream.Close()
$icon.Dispose()
$bmp.Dispose()
```

```powershell
# ImageMagickで変換
magick resources/icon.png resources/icon.ico
```

## プロジェクト構成

```tree
mouse/
├── resources/
│   ├── icon.ico          # アプリケーションアイコン
│   ├── icon.png          # アイコンソースファイル
│   └── resource.rc       # Windowsリソース定義
├── src/
│   ├── main.zig          # メインプログラム（ウィンドウ、描画、イベント処理）
│   ├── platform.zig      # プラットフォーム抽象レイヤー
│   ├── platform_windows.zig  # Windowsプラットフォーム実装
│   └── root.zig          # ライブラリエントリ
├── build.zig             # ビルドスクリプト
├── build.zig.zon         # パッケージ設定
├── README.md
├── README.ja.md
└── CHANGELOG.md
```

## 技術アーキテクチャ

### プラットフォーム抽象化

`platform.zig` が統一インターフェースを提供し、`platform_windows.zig` がWindows固有の機能を実装：

```bash
copyToClipboard    - テキストをクリップボードにコピー
createTrayIcon     - システムトレイアイコンを作成
showTrayMenu       - トレイ右クリックメニューを表示
minimizeToTray     - トレイに最小化
restoreFromTray    - トレイから復元
removeTrayIcon     - トレイアイコンを削除
isWindowVisible    - ウィンドウの可視性を取得
openAboutUrl       - プロジェクトページを開く
loadAppIcon        - アプリケーションアイコンを読み込み
```

### レンダリング

- ダブルバッファリングGDI描画、ちらつきなし
- 2つの描画モード：`renderUI`（フル）と `renderUICompact`（コンパクト）
- 角丸ウィンドウ、ダークテーマ
- ClearTypeフォントレンダリング

### UI構成要素

| コンポーネント | 説明 |
|--------------|------|
| タイトルバー | アプリ名 + 状態インジケータ + 閉じるボタン |
| 座標カード | X/Y大文字座標 + パーセンテージ |
| 軌跡チャート | 60フレームのX/Y移動履歴曲線 |
| 情報カード | 論理解像度 + 物理解像度 |
| プログレスバー | X/Y座標の進捗を可視化 |
| ステータスバー | ロック状態 + コピー通知 + 追従モード |

## ライセンス

MIT License

## プロジェクトリンク

[https://github.com/MakotoArai-CN/mouse-tracker](https://github.com/MakotoArai-CN/mouse-tracker)
