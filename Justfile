pnx := "pnx --allow-build esbuild --allow-build workerd"

build:
    {{ pnx }} wrangler build

deploy:
    {{ pnx }} wrangler deploy

dev:
    {{ pnx }} wrangler dev
