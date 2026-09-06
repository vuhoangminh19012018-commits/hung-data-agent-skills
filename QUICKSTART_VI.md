# Bắt đầu nhanh — Hung Data Agent Skills

Repo này dành cho đúng kiểu làm việc: **AI coding agent phải hiểu repo trước, sửa ít nhất có thể, test rồi mới báo xong**.

## 1. Cài skill trên Windows

Mở PowerShell tại thư mục repo này:

```powershell
.\scripts\install.ps1
```

Mặc định script copy 12 skill vào:

```text
%USERPROFILE%\.agents\skills
```

Muốn cài chỗ khác:

```powershell
.\scripts\install.ps1 -Target "D:\AI\skills"
```

## 2. Gắn quy tắc vào project mapping hiện tại

Copy file:

```text
templates\AGENTS.md
```

vào thư mục gốc project code và sửa `<skills-repo>` thành đường dẫn thật tới repo skill này.

## 3. Sau đó nói với coding agent bình thường

Ví dụ:

```text
check git và làm tiếp
```

Agent nên kích hoạt `inspect-repo`, sau đó mới đọc task và sửa.

```text
PART NO khác nhau do dấu cách, dấu chấm, dấu gạch; sửa normalize nhưng tránh match nhầm
```

Agent nên dùng `normalize-business-keys`, viết cặp test match / không-match rồi mới sửa.

```text
Qwen trả candidate đúng nhưng hệ thống vẫn map nhầm
```

Agent nên dùng `systematic-debugging` và kiểm tra riêng candidate retrieval với confidence/decision gate.

```text
đánh giá vector có thực sự tốt hơn pg_trgm không
```

Agent nên dùng `evaluate-mapping-quality`: tách train/test trước, tránh leakage, so cùng một held-out set.

## 4. Pipeline repo này bảo vệ

```text
Raw Excel/CSV
  -> profile cột
  -> normalize
  -> exact/rule
  -> Qwen3-Embedding-0.6B
  -> pgvector Top 5-20
  -> confidence gate
  -> low confidence = review / future remote LLM fallback
  -> Excel audit
```

LLM sinh văn bản local **không phải dependency mặc định**. API bên ngoài **không được tự bật**.

## 5. Kiểm tra repo skill

```powershell
python .\scripts\validate_skills.py
```

Kết quả đúng hiện tại:

```text
PASS: 12 skills valid
```

## 6. 4 skill bạn sẽ dùng nhiều nhất

- `inspect-repo`: câu "check git".
- `systematic-debugging`: có lỗi nhưng chưa biết lỗi ở stage nào.
- `build-mapping-pipeline`: thay đổi logic mapping.
- `verify-before-finish`: bắt buộc test rồi mới được báo xong.

Các skill còn lại tự bổ sung khi công việc đụng Excel, normalize, vector, SQL hoặc đánh giá chất lượng.
