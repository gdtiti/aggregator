# Subscribe Pipeline 兼容性约束

- 更新时间：2026-03-27
- 来源提交：`7659d28`、`4a06042`、`2512a84`
- 适用范围：`subscribe/airport.py`、`subscribe/clash.py`、`subscribe/location.py`、`subscribe/process.py`

## 已升级为正式知识

### 订阅行解析

- `AirPort.check_protocol()` 现在接受 `socks5`、`http`、`https` 作为合法协议前缀。
- `AirPort.decode()` 在判断“整段文本是否为纯协议行订阅并需要先做 base64 包装”时，会忽略空行和以 `#` 开头的注释行。
- 含注释的纯链接订阅不应再因为注释行而走错解析分支。
- 代码依据：`subscribe/airport.py:701`、`subscribe/airport.py:758`

### VLESS Reality short-id 校验

- `reality-opts.short-id` 不再要求固定 8 个十六进制字符。
- 当前规则是：`bytes.fromhex(short_id)` 必须成功，且解码后的二进制长度不能超过 8 字节。
- 该字段通过校验后仍会以 `QuotedStr` 写回配置。
- 代码依据：`subscribe/clash.py:575-602`

### residential regularize 的 provider 选择

- `location.regularize()` 新增 `ip_library` 参数。
- `process.aggregate()` 从 `groups.<name>.regularize.library` 读取首选 provider，并传入 `location.regularize()`。
- 支持值：`ip2location`、`iplark`、`ippure`、`ipinfo`、`ipapi`。
- 非法值会回退到 `ip2location`，之后再按候选列表继续 fallback。
- 代码依据：`subscribe/process.py:642-654`、`subscribe/location.py:839-899`、`subscribe/location.py:983-1045`、`subscribe/location.py:1291-1322`

## 当前文档差异

- 公开文档尚未写入 `regularize.library`：
  - `README_CN.md:954-981`
  - `README_EN.md:529-534`
  - `subscribe/config/config.default.json:168-172`
- 这是当前代码已生效、但用户文档未同步的事实；若后续要对外发布配置说明，应优先补齐。
