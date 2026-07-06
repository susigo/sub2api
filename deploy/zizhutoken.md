# Token自助站部署备忘

目标站点：

- 站名：Token自助站
- 域名：zizhutoken.xyz
- 默认访问地址：https://zizhutoken.xyz

## 1. DNS

在域名服务商处添加：

```text
A     @     你的服务器 IPv4
A     www   你的服务器 IPv4
```

如果服务器有 IPv6，再补 `AAAA` 记录。

## 2. Docker 部署

推荐用本目录的本地数据版 compose：

```bash
cd deploy
cp .env.example .env
```

至少修改这些值：

```env
ADMIN_EMAIL=admin@zizhutoken.xyz
POSTGRES_PASSWORD=替换为强密码
JWT_SECRET=替换为32字节以上随机字符串
TOTP_ENCRYPTION_KEY=替换为32字节以上随机字符串
```

启动：

```bash
docker compose -f docker-compose.local.yml up -d
docker compose -f docker-compose.local.yml logs -f sub2api
```

首次如果没有设置 `ADMIN_PASSWORD`，从日志里找自动生成的管理员密码。

## 3. Caddy 反代

本目录 `Caddyfile` 已改为：

```caddy
zizhutoken.xyz, www.zizhutoken.xyz {
    reverse_proxy localhost:8080
}
```

Caddy 会自动申请 HTTPS 证书。部署后确认服务器 80/443 端口已开放。

## 4. 后台站点设置

登录管理后台后，在系统设置里确认：

```text
网站名称: Token自助站
网站副标题: Token self-service API gateway
API端点地址: https://zizhutoken.xyz
文档链接: https://zizhutoken.xyz
客服联系方式: 填你的联系方式
```

代码默认值已经改成 `Token自助站`，但老数据库如果曾经初始化过 `site_name=Sub2API`，后台保存一次站点设置即可覆盖。
