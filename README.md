# terraform-demo

## 事前準備
- [installation](https://github.com/direnv/direnv/blob/master/docs/installation.md#installation)を参考にdirenvをインストール

- [setup](https://github.com/direnv/direnv/blob/master/docs/hook.md#setup)を参考にPATHを通す
  - direnvをaquaで管理するとbashrcでのhookに失敗する

- [Install Aqua](https://aquaproj.github.io/docs/reference/install#homebrew)を参考にAquaをインストールし、PATHを通す

- terraform, aws-cliなどaquaでバージョン管理しているCLIをインストールする
```bash
$ aqua i
```

## ディレクトリ構成
```bash
.
├── README.md
├── aqua.yaml                                              # config of aqua
├── modules                                                # terraform modules 独自運用するmoduleがあればここに書く
├── renovate.json                                          # config of Renovate
└── services                                               # services
    ├── argocd_demo                                        # serviceごとにtfstateを分割
    ├── platform                                           # 基盤
    │   ├── production
    │   │   ├── main.tf -> ../staging/main.tf              # 環境間の差分を減らすためsymlinkを使う
    │   │   ├── production.tfbackend                       # terraform init --backend-config=production.tfbackend としてinit時に変数を渡す
    │   │   ├── providers.tf -> ../staging/providers.tf
    │   │   ├── terraform.tfvars                           # variablesのデフォルト値をoverrideする。環境間の設定差分はここでカバーする
    │   │   └── variables.tf -> ../staging/variables.tf
    │   └── staging
    │       ├── main.tf                                    # 主処理。直接リソースを定義すると肥大化してしまうためmoduleを呼び出す
    │       ├── providers.tf                               # terraform providerの設定を定義
    │       ├── staging.tfbackend                          # terraform backendの変数を定義
    │       ├── staging_only.tf                            # stagingにしか作らないリソースがあればここで定義
    │       ├── terraform.tfvars                           # variablesのデフォルト値をoverrideする。環境間の設定差分はここでカバーする
    │       └── variables.tf                               # 変数の定義
    └── prometheus_demo
```
