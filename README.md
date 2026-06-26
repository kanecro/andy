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
├── install.sh                      # ~/.fugu への基本インストール + optional global shims
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

安全なデフォルトでは、`${FUGU_HOME:-$HOME/.fugu}` だけに symlink を作成します。

```bash
cd /Users/kaneshiro/Projects/github.com/kanecro/andy
./install.sh
```

作成されるもの:

```text
~/.fugu/
├── harnesses/andy -> /path/to/andy
├── AGENTS.md -> harnesses/andy/AGENTS.md
├── CLAUDE.md -> harnesses/andy/CLAUDE.md
├── GEMINI.md -> harnesses/andy/GEMINI.md
├── andy.config.template.json -> harnesses/andy/adapters/fugu/config.template.json
└── active-harness -> harnesses/andy
```

既存ファイルがある場合は、確認のうえ `~/.fugu/backups/andy-YYYYMMDD-HHMMSS/` に退避します。CIや非対話で使う場合は `-y` を付けてください。

```bash
./install.sh -y
```

## Optional: 各エージェントのグローバル入口にも入れる

既存の個別エージェント設定と衝突し得るため、デフォルトでは `~/.codex` / `~/.claude` / `~/.gemini` には触りません。必要な場合だけ明示します。

```bash
./install.sh --with-codex   # ~/.codex/AGENTS.md
./install.sh --with-claude  # ~/.claude/CLAUDE.md
./install.sh --with-gemini  # ~/.gemini/GEMINI.md
./install.sh --all-agents   # 上記すべて
```

## アンインストール

```bash
./uninstall.sh
```

andy が作成した symlink のみ削除します。`~/.fugu/config.json` などのユーザー設定は削除しません。

optional global shims も削除する場合:

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
