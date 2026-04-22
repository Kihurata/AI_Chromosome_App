# 📊 Bảng Theo Dõi Tiến Độ Dự Án (AI Chromosome App)

Tệp này giúp theo dõi trạng thái thực tế của các kế hoạch và tài liệu trong thư mục `docs/`.

---

## 🏗️ 1. Nguyên Tắc Thiết Kế Cốt Lõi (Core)
*Các tài liệu định hình nền tảng cấu trúc của dự án.*

- [x] [Kiến trúc Hệ thống (ARCHITECTURE)](core/ARCHITECTURE.md)
- [x] [Luồng Dữ liệu (DATAFLOW)](core/DATAFLOW.md)
- [x] [Hệ thống Thiết kế UI (UI_DESIGN_SYSTEM)](core/UI_DESIGN_SYSTEM.md)
- [x] [Quyết định Kỹ thuật: State Management](core/ADR-state-management.md)

---

## 🧩 2. Trạng Thái Các Module
*Theo dõi tiến độ triển khai thực tế của từng tính năng.*

### 👩‍💼 Module: Tiếp Tân (Receptionist)
| Kế hoạch | Trạng thái | Ghi chú |
| :--- | :---: | :--- |
| [Thiết kế Module & DB](modules/receptionist/PLAN-receptionist-module.md) | ✅ 100% | Đã hoàn thành cấu trúc nền. |
| [Nâng cấp UI (Update 2)](modules/receptionist/PLAN-receptionist-updates.md) | ✅ 95% | Patient Detail (Timeline) đã xong. |
| [Kế hoạch Kiểm thử](modules/receptionist/PLAN-receptionist-test.md) | 🔄 20% | Cần chạy test suite và quét coverage. |

---

## 📂 3. Cấu Trúc Thư Mục Docs
```text
docs/
├── core/       # Nguyên tắc, kiến trúc & design system
├── modules/    # Kế hoạch triển khai chi tiết từng folder
├── archive/    # Các kế hoạch cũ đã đóng
└── PROGRESS.md # Tệp này (Dashboard chính)
```

---

## 🚀 4. Nhiệm Vụ Tiếp Theo (Next Steps)
1. **Hoàn tất Kiểm thử**: Chạy tích hợp các tệp test cho Module Receptionist.
2. **Module Bác sĩ (Doctor)**: Bắt đầu thiết kế giao diện cho tab "Kết quả Xét nghiệm".
3. **Đồng bộ hóa Docs**: Cập nhật trạng thái `[x]` vào các tệp PLAN tương ứng trong `modules/receptionist/`.

---
*Cập nhật lần cuối: 22/04/2026*
