# andy Core Principles

## 1. Model-agnostic orchestration

andy は特定モデルに依存しない。Fugu が利用可能なモデルやworkerを選ぶ。andy は「どのモデルか」ではなく「どの役割・能力・成果物が必要か」を指定する。

## 2. Artifact-driven development

会話だけで開発を進めない。重要な判断は artifact に落とす。

- Proposal: なぜ・何を作るか
- Design: どう作るか
- Tasks: 実装単位
- Delta Spec: 振る舞い仕様
- Traceability: 要件から実装・テストへの対応
- Review Summary: レビューと対応
- Compound Learning: 学び

## 3. Small, reversible changes

不可逆な判断を早期に検出し、ユーザーに確認する。可逆な実装詳細はworkerに委ねてよい。

## 4. Verification is a first-class artifact

「通るはず」ではなく、実行したコマンドと出力を根拠にする。

## 5. Parallelism requires ownership

並列workerは便利だが、write scope が曖昧だと破壊的。各workerには所有ファイル・禁止ファイル・完了条件を渡す。
