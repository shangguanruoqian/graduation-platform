-- 毕业证学位证代领邮寄管理平台 - 数据库初始化
-- 在 Supabase SQL Editor 中执行此文件

-- 1. 学生表（白名单）
CREATE TABLE IF NOT EXISTS students (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id  varchar(50) UNIQUE NOT NULL,
  name        varchar(100) NOT NULL,
  class_name  varchar(100),
  dormitory   varchar(50),
  phone       varchar(20),
  role        varchar(20) DEFAULT 'student' CHECK (role IN ('student','monitor','admin')),
  is_active   boolean DEFAULT true,
  created_at  timestamptz DEFAULT now()
);

-- 2. 委托表（含宿舍验收 + 邮寄信息）
CREATE TABLE IF NOT EXISTS delegations (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id      uuid REFERENCES students(id) NOT NULL,
  status          varchar(30) DEFAULT 'draft',

  -- 个人信息快照
  personal_info   jsonb DEFAULT '{}',
  -- 邮寄地址
  mailing_address jsonb DEFAULT '{}',
  -- 证书类型: graduation / degree / both
  certificate_types varchar(50) DEFAULT 'both',

  -- 上传文件 URL（Supabase Storage 路径）
  id_card_front_url     text,
  id_card_back_url      text,
  signature_url         text,
  packaging_video_url   text,

  -- 宿舍验收（内嵌）
  inspection_status     varchar(30) DEFAULT 'pending',
  inspection_notes      text,
  inspection_photo_urls jsonb DEFAULT '[]',
  inspected_by          uuid REFERENCES students(id),
  inspected_at          timestamptz,

  -- 邮寄信息（内嵌）
  courier_company       varchar(50),
  tracking_number       varchar(100),
  estimated_departure   date,
  mailed_at             timestamptz,
  mailed_by             uuid REFERENCES students(id),

  -- 通用
  notes         text,
  submitted_at  timestamptz,
  created_at    timestamptz DEFAULT now(),
  updated_at    timestamptz DEFAULT now()
);

CREATE INDEX idx_delegations_student ON delegations(student_id);
CREATE INDEX idx_delegations_status  ON delegations(status);

-- 3. 操作日志
CREATE TABLE IF NOT EXISTS activity_logs (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id    uuid REFERENCES students(id),
  delegation_id uuid REFERENCES delegations(id),
  action        varchar(100) NOT NULL,
  details       jsonb DEFAULT '{}',
  created_at    timestamptz DEFAULT now()
);

CREATE INDEX idx_logs_delegation ON activity_logs(delegation_id);
CREATE INDEX idx_logs_created     ON activity_logs(created_at DESC);

-- 4. 会话表
CREATE TABLE IF NOT EXISTS sessions (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id  uuid REFERENCES students(id) NOT NULL,
  token       varchar(255) UNIQUE NOT NULL,
  expires_at  timestamptz NOT NULL,
  created_at  timestamptz DEFAULT now()
);

CREATE INDEX idx_sessions_token ON sessions(token);

-- 5. Supabase Storage 配置
-- 在 Supabase Dashboard → Storage 手动创建以下 bucket：
--   id-cards      (5MB, jpg/png/webp)  — 设为 public
--   signatures    (1MB, png)            — 设为 public
--   videos        (200MB, mp4/webm/mov) — 设为 public
--   inspection    (10MB, jpg/png/webp)  — 设为 public
-- 注意：本工具为班级内部使用，bucket 设为 public 以简化访问。

-- 6. 种子数据示例（修改为实际学生名单后执行）
-- INSERT INTO students (student_id, name, class_name, dormitory, phone, role) VALUES
-- ('20210001', '张三', '计算机2101', '1-301', '13800000001', 'student'),
-- ('20210002', '李四', '计算机2101', '1-301', '13800000002', 'student'),
-- ('20210099', '梁怀洲', '计算机2101', '1-302', '18763125603', 'monitor');
