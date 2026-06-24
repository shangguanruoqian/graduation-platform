# 毕业证学位证代领邮寄管理平台 - 部署指南

## 一、创建 Supabase 项目（5分钟）

1. 打开 https://supabase.com ，注册/登录
2. 点击 "New project"，填写项目名称（如 `graduation-platform`）
3. 设置数据库密码（牢记），选择最近的区域，创建
4. 等待项目初始化（约2分钟）

## 二、初始化数据库

1. 进入 Supabase Dashboard → SQL Editor
2. 复制 `migration.sql` 的全部内容，粘贴并执行
3. 执行成功后，左侧会出现 `students`、`delegations`、`activity_logs`、`sessions` 四张表

## 三、创建存储桶

1. 进入 Supabase Dashboard → Storage
2. 点击 "New bucket"，分别创建以下 4 个 bucket（全部勾选 "Public bucket"）：
   - `id-cards`
   - `signatures`
   - `videos`
   - `inspection`

## 四、导入学生数据

在 SQL Editor 中执行（修改为实际名单）：

```sql
INSERT INTO students (student_id, name, class_name, dormitory, phone, role) VALUES
('学号1', '姓名1', '班级1', '宿舍号1', '电话1', 'student'),
('学号2', '姓名2', '班级2', '宿舍号2', '电话2', 'student'),
...
('班长学号', '梁怀洲', '班级', '宿舍号', '18763125603', 'monitor');
```

## 五、配置前端

1. 打开 Supabase Dashboard → Settings → API
2. 复制 `Project URL` 和 `anon public key`
3. 打开 `index.html`，将第 322-323 行替换为你的信息：

```javascript
const SUPABASE_URL = 'https://xxxxx.supabase.co';  // 你的 Project URL
const SUPABASE_KEY = 'eyJhbG...';                   // 你的 anon key
```

## 六、部署上线（Vercel，免费）

1. 将整个 `graduation-platform` 目录上传到 GitHub 仓库
2. 打开 https://vercel.com ，注册/登录
3. 点击 "New Project" → 导入你的 GitHub 仓库
4. 无需配置环境变量，直接 Deploy
5. 部署完成后获得链接，发给同学即可

## 七、本地测试

如果只想本地使用，双击 `index.html` 即可在浏览器打开（需先完成步骤五的配置）。

---

**链接示例**
- 学生端：`https://你的域名` → 输入学号+姓名登录
- 班长端：同样链接，用班长学号+姓名登录
