---
id: 49of6r
title: Wire Logic for Clinician Forms
status: in-progress
priority: high
labels:
  - clinician
  - ui
  - integration
createdAt: '2026-05-03T04:42:29.148Z'
updatedAt: '2026-05-03T06:46:04.158Z'
timeSpent: 0
---
# Wire Logic for Clinician Forms

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Chuyển đổi và gắn logic xử lý cho các màn hình forms của bác sĩ (ClinicianExaminationFormPage và ClinicianBloodTestPrescriptionPage). Lấy dữ liệu bệnh nhân thực tế và kết nối với ClinicianOrderCubit để lưu phiếu.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Domain (Appointment): Định nghĩa enum AppointmentStatus với 4 trạng thái cốt lõi: scheduled, inProgress, completed, cancelled. Cập nhật Appointment entity.
2. Domain (Examination): Tạo Examination entity & repository interface.
3. Data Layer: Cập nhật AppointmentModel để serialize/deserialize enum. Tạo ExaminationModel & ExaminationRepositoryImpl.
4. Logic Layer: Tạo CreateExamination usecase & ExaminationCubit. Cập nhật AppointmentCubit xử lý 4 trạng thái trên.
5. UI (Bảng danh sách): Cập nhật RecentPatientsTable thêm cột 'KQXN' để hiển thị độc lập TestOrderStatus (từ test_order_model), giữ cột 'Trạng thái' cho AppointmentStatus.
6. UI (Forms): Refactor examination_form_screen & blood_test_prescription_screen. Cấu hình luồng: Lưu tự động phiếu khám khi ấn Tạo Phiếu Xét Nghiệm, và đổi trạng thái lịch hẹn khi Lưu/Hủy.
<!-- SECTION:PLAN:END -->

