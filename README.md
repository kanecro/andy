# andy

andy は、Fugu / Codex / Claude / Gemini / 将来のコーディングエージェントで共通して使えることを目指す、エージェント中立のユーザーレベル開発ハーネスです。

特定モデル名に依存せず、workflow・role・policy・artifact・guardrail を定義します。Fugu を主な利用先としつつ、Codex-style の `AGENTS.md`、Claude-style の `CLAUDE.md`、Gemini-style の `GEMINI.md` からも同じ正本へ到達できる構成です。

## 設計方針

1. **モデル選択はランタイムに任せる**  
   ハーネスは `Claude` / `Codex` / `Opus` / `Sonnet` などのモデル名をプロセスとして固定しません。代わりに `capability_profile`（例: reasoning high, code_editing true, review adversarial）を定義します。

2. **`AGENTS.md` を唯一の正本にする**  
   `CLAUDE.md` / `GEMINI.md` は薄い互換 shim です。共通指示は `AGENTS.md` に集約します。

3. **Core / Adapter 分離**  
   `core/` はモデル・ランタイム非依存の作業規約です。`adapters/` は各ランタイムで使うための対応表です。

4. **OpenSpec系アーティファクトを維持**  
   `proposal.md` / `design.md` / `tasks.md` / `delta-spec.md` / `traceability.md` / `review-summary.md` を、どのエージェントでも使える成果物契約として扱います。

5. **決定論的ガードレールを重視**  
   特定ツールの hook ではなく、Fugu・Codex・Claude・Gemini・CI・手動preflightから呼べる `scripts/guardrails/` として配置します。

6. **Coordinator は薄く、worker は明確な責務とwrite scopeを持つ**  
   並列実装では、各workerの所有ファイルを明確化し、他workerの変更をrevertしないことを明示します。


## ルール階層

andy はルールを2層に分けます。

1. **不変ルール**: どのエージェント・どのプロジェクトでも弱めてはいけないルール。`core/policies/immutable-rules.md` に定義。
2. **上書きルール**: プロジェクトごとの技術スタック、コマンド、規約、ドキュメント同期など。`core/policies/project-overrides-policy.md` に定義。

優先順位と衝突時の扱いは `core/policies/rule-precedence-policy.md` に定義しています。

プロジェクト側では、必要に応じて以下を置きます。

```text
<project>/AGENTS.md
<project>/.andy/overrides.md
<project>/.andy/verification.md
<project>/.andy/workflows.md
```

テンプレートは `templates/project/` にあります。

## ディレクトリ構成

```text
andy/
├── AGENTS.md                       # canonical agent entrypoint
├── CLAUDE.md                       # Claude-style shim → AGENTS.md
├── GEMINI.md                       # Gemini-style shim → AGENTS.md
├── install.sh                      # ~/.codex への基本インストール
├── uninstall.sh                    # symlink uninstall
├── core/                           # ランタイム非依存のハーネス本体
│   ├── principles.md
│   ├── workflows/
│   ├── roles/
│   ├── policies/
│   ├── skills/
│   ├── artifact-schemas/
│   └── guardrails/
├── adapters/
│   ├── fugu/
│   ├── codex/
│   ├── claude/
│   └── gemini/
├── scripts/
│   ├── validate-harness.sh
│   └── guardrails/
├── templates/project/
└── docs/plans/
```

## インストール

デフォルトでは、`${CODEX_HOME:-$HOME/.codex}` にハーネス本体と Codex entrypoint を配置します。
`codex` / `codex-fugu` はどちらも Codex 互換の `AGENTS.md` を読むため、andy の有効化先は `~/.codex` に一本化しています。

```bash
cd /Users/kaneshiro/Projects/github.com/kanecro/andy
./install.sh
```

作成されるもの:

```text
~/.codex/
├── harnesses/andy -> /path/to/andy
├── AGENTS.md -> harnesses/andy/AGENTS.md
├── andy.config.template.json -> harnesses/andy/adapters/fugu/config.template.json
├── andy.config.json
└── active-harness -> harnesses/andy
```

既存ファイルがある場合は、確認のうえ `~/.codex/.andy-backups/andy-YYYYMMDD-HHMMSS/` に退避します。CIや非対話で使う場合は `-y` を付けてください。

```bash
./install.sh -y
```

別の Codex home に入れる場合は `--target` か `CODEX_HOME` を指定します。

```bash
./install.sh --target /path/to/codex-home
```

## Optional: Claude / Gemini のグローバル入口にも入れる

既存の個別エージェント設定と衝突し得るため、デフォルトでは `~/.claude` / `~/.gemini` には触りません。必要な場合だけ明示します。

```bash
./install.sh --with-claude  # ~/.claude/CLAUDE.md
./install.sh --with-gemini  # ~/.gemini/GEMINI.md
./install.sh --all-agents   # Claude / Gemini も有効化
```

## アンインストール

```bash
./uninstall.sh
```

andy が作成した symlink のみ削除します。デフォルトでは `~/.codex` 側の andy symlink を削除します。`~/.codex/andy.config.json` などのユーザー設定は削除しません。

Claude / Gemini の global shims も削除する場合:

```bash
./uninstall.sh --all-agents
```

## 検証

```bash
./scripts/validate-harness.sh
```

## 使い方

- どのエージェントでも、まず `AGENTS.md` を正本として扱います。
- Claude-style runtime では `CLAUDE.md` が `AGENTS.md` を import します。
- Gemini-style runtime では `GEMINI.md` が `AGENTS.md` を import します。
- Fugu では `adapters/fugu/config.template.json` の `entrypoint` が `AGENTS.md` です。

### 基本の呼び出し方

andy は特定ランタイムの slash command ではなく、`core/workflows/` 配下の workflow runbook をエージェントに読ませて使います。

例:

```text
AGENTS.md を正本として読み、core/workflows/brainstorm.md に従って、次のアイデアを要件整理してください:
「通知機能を追加したい」
```

```text
AGENTS.md と core/workflows/spec.md に従って、openspec/changes/add-notifications/proposal.md から仕様・設計・タスクを作成してください。
```

```text
AGENTS.md と core/workflows/implement.md に従って、承認済みの tasks.md を実装してください。並列化できる場合はworkerごとにwrite scopeを分けてください。
```

### 標準ワークフロー

```text
brainstorm → spec → implement → review → test → compound
```

| Phase | Runbook | 目的 | 主な出力 |
|---|---|---|---|
| brainstorm | `core/workflows/brainstorm.md` | アイデアを小さく検証可能な提案にする | `openspec/changes/<change-name>/proposal.md` |
| spec | `core/workflows/spec.md` | 提案を仕様・設計・タスクへ落とす | `design.md`, `tasks.md`, `specs/<feature>/delta-spec.md`, `traceability.md` |
| implement | `core/workflows/implement.md` | 承認済みタスクを最小差分・TDDで実装する | 実装コード、テスト、変更サマリー |
| review | `core/workflows/review.md` | 仕様準拠・品質・リスクをレビューする | `reviews/review-summary.md` |
| test | `core/workflows/test.md` | L1/L2/L3の検証を実行し証拠を残す | テスト結果、検証ログ |
| compound | `core/workflows/compound.md` | 学びを蓄積し次回に還元する | `docs/compound/YYYY-MM-DD-<topic>.md` |
| ship | `core/workflows/ship.md` | approval gate付きで一連の流れを実行する | 完了レポート |

### brainstorm の使い方

`brainstorm` は、まだ曖昧なアイデアを proposal にする入口です。

依頼例:

```text
AGENTS.md を読み、core/workflows/brainstorm.md に従ってbrainstormしてください。
テーマ: ユーザーがメール通知を受け取れるようにしたい
```

エージェントは以下を行います。

1. 一度に1つずつ質問する。
2. 可能なら選択肢形式で質問する。
3. YAGNIでスコープ外を明確にする。
4. `story-quality-gate` の観点でユーザーストーリーを確認する。
5. 各ストーリーの検証観点を確認する。
6. `openspec/changes/<change-name>/proposal.md` を作成する。
7. `spec` に進む前にユーザー承認を取る。

出力される proposal の基本構造:

```markdown
# <change-name> Proposal

## Intent

## User Stories

## Scope

## Out of Scope

## Technical Considerations

## Open Questions
```

### spec 以降の使い方

brainstorm 後、ユーザーが proposal を承認したら `spec` に進みます。

```text
core/workflows/spec.md に従って、openspec/changes/<change-name>/proposal.md から design.md / tasks.md / delta-spec.md / traceability.md を作成してください。
```

spec 承認後は、実装以降を進めます。

```text
core/workflows/implement.md に従って、openspec/changes/<change-name>/tasks.md を実装してください。
```

```text
core/workflows/review.md に従って、今回の変更を仕様準拠・品質・リスクの観点でレビューしてください。
```

```text
core/workflows/test.md に従って、L1/L2/L3の検証を実行し、結果を証拠つきで報告してください。
```

```text
core/workflows/compound.md に従って、今回の学びを docs/compound/ に記録してください。
```

### プロジェクトごとの上書き

プロジェクトに andy を適用する場合は、`templates/project/` を参考にしてプロジェクト側へ以下を置きます。

```text
<project>/AGENTS.md
<project>/.andy/overrides.md
```

プロジェクト側では、テストコマンド・ディレクトリ構成・ドキュメント同期・ドメイン固有ルールを上書きできます。ただし、`core/policies/immutable-rules.md` の不変ルールは弱められません。
