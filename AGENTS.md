# Repository Guidelines

## 記述言語
- リポジトリ内の説明・ドキュメントは原則日本語で記載します。コード内コメントも必要に応じて日本語で簡潔にまとめてください。

## プロジェクト構成とモジュール
- ルートに `Codex-CLI-251122.xcodeproj` とアプリ本体 `Codex-CLI-251122/` が置かれます。
- `Codex_CLI_251122App.swift` が SwiftUI アプリを起動し `ContentView.swift` にルーティングします。新規ビューは同階層か機能別フォルダに追加してください。
- 画像やカラーは `Codex-CLI-251122/Assets.xcassets` に集約し、`onboarding-hero` や `brand-blue` のように用途が伝わる命名を使います。
- Previews は各ビューに隣接させ、重いデバッグ専用のヘルパーは `#if DEBUG` で囲みます。

## ビルド・テスト・開発コマンド
- `open Codex-CLI-251122.xcodeproj` — Xcode を起動しシミュレータ/デバイス実行を開始します。
- `xcodebuild -project Codex-CLI-251122.xcodeproj -scheme "Codex-CLI-251122" -destination 'platform=iOS Simulator,name=iPhone 15' build` — CLI で Xcode 相当のビルドを行います。
- `xcodebuild -project Codex-CLI-251122.xcodeproj -scheme "Codex-CLI-251122" -destination 'platform=iOS Simulator,name=iPhone 15' test` — XCTest スイートを実行します。`-quiet` でログ量を抑制できます。

## コーディングスタイルと命名
- Swift 5/SwiftUI、インデントは4スペース。型は `CamelCase`、変数/関数は `lowerCamelCase`、定数は `let` を優先。
- 小さく合成可能な View を心がけ、`body` が膨らむ前にサブビューへ抽出。スタイルは使用箇所近くのモディファイアで完結させます。
- View は `struct` を既定とし、ヘルパーは `private` に。状態は最小化し、計算で代替できる値は保持しません。
- Swift API Design Guidelines に沿い、動作は動詞ベースのメソッド名 (`loadData()`)、値は名詞ベース、引数ラベルで副作用を明示します。
- モデルの定義は原則1ファイルにつき1つとし、責務を分割したシンプルな構造を保ちます。

## テスト方針
- `Codex-CLI-251122Tests` ターゲットを追加し、`XCTestCase` で単体/UI テストを実装します。フィクスチャはテストターゲット側に置き、アプリ本体に混在させません。
- テスト名は `testComponent_State_Expectation` 形式で意図を明確にします。決定的な入力を使い、シミュレータのロケールや時刻依存は避けます。
- ロジックが多い ViewModel やフォーマッタを優先的にカバーし、成長に合わせて 80% 以上のカバレッジを目指します。
- 実行は Xcode の Test アクションまたは上記 `xcodebuild ... test` で行い、警告・失敗はマージ前に必ず解消します。

## コミットとプルリクエスト
- コミットメッセージは日本語で記述してください。
- 小さく焦点を絞ったコミットにし、命令形・現在形で要約します（例: `Add onboarding hero view`）。無関係な変更をまとめないでください。
- PR には簡潔な概要、関連 Issue/参照、UI 変更のスクリーンショット、実行したテスト計画（コマンドや確認シナリオ）を含めます。
- ブランチは常に main にリベースし、大きなマージコミットを避けます。コンフリクトはレビュー依頼前にローカルで解消します。

## セキュリティと設定
- シークレットや個人情報をコミットしないでください。API キーは Xcode の設定ファイルや環境変数で管理します。
- サードパーティ資産はライセンスを確認・明記し、大きなバイナリは git に直置きせずアセットカタログか外部ストレージを利用します。
