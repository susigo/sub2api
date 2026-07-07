# 源码部署与更新（susigo/sub2api）

## 推荐：GitHub Actions 构建 + VPS 拉取镜像

适合 1GB 等小内存 VPS：在 GitHub 上编译镜像，服务器只 `docker pull`，无需本地构建。

### 1. 推送代码触发构建

向 `main` 分支 push 后，工作流 [docker-main.yml](../.github/workflows/docker-main.yml) 会自动构建并推送到：

```text
ghcr.io/susigo/sub2api:main
ghcr.io/susigo/sub2api:latest
ghcr.io/susigo/sub2api:sha-<commit>
```

也可在 GitHub → **Actions** → **Docker Build (main)** → **Run workflow** 手动触发。

### 2. 将 GHCR 包设为公开（首次）

1. 打开 https://github.com/susigo/sub2api/pkgs/container/sub2api
2. **Package settings** → **Change visibility** → **Public**

若保持私有，VPS 需先登录 GHCR（见下文）。

### 3. VPS 首次配置

```bash
git clone https://github.com/susigo/sub2api.git /opt/sub2api-app
cd /opt/sub2api-app/deploy
cp .env.example .env
# 编辑 .env（数据库密码、JWT 等）
# 可选：GHCR_IMAGE=ghcr.io/susigo/sub2api:main

chmod +x update-ghcr.sh
./update-ghcr.sh
```

私有镜像登录（仅私有包需要）：

```bash
# 在 GitHub 创建 PAT，勾选 read:packages
echo 'YOUR_GITHUB_PAT' | docker login ghcr.io -u susigo --password-stdin
```

### 4. 日常更新

```bash
# 1. 本地改代码并 push 到 main，等 Actions 构建完成（约 5–10 分钟）
# 2. VPS 上执行：
cd /opt/sub2api-app/deploy
./update-ghcr.sh
```

### 5. 域名与 Caddy

Caddy 反代不变：`https://你的域名` → `127.0.0.1:8080`。`.env` 中建议：

```env
BIND_HOST=127.0.0.1
```

---

## 备选：VPS 本地构建（需 2GB+ 内存或 swap）

见 `update.sh`、`build-frontend.sh`、`Dockerfile.prebuilt`。小内存机器易 OOM，不推荐。

---

## 常用命令

```bash
cd /opt/sub2api-app/deploy

# GHCR 模式
docker compose -f docker-compose.local.yml -f docker-compose.ghcr.yml ps
docker compose -f docker-compose.local.yml -f docker-compose.ghcr.yml logs -f sub2api

# 本地构建模式
docker compose -f docker-compose.local.yml -f docker-compose.build.yml ps
```
