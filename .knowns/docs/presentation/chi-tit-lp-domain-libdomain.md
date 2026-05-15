---
title: Chi tiết lớp Domain (lib/domain)
description: Tài liệu chi tiết về lớp Domain (lib/domain), bao gồm Entities, Repositories (Interface) và UseCases.
createdAt: '2026-05-13T07:54:15.553Z'
updatedAt: '2026-05-13T07:54:24.876Z'
tags:
  - architecture
  - domain-layer
  - clean-architecture
---

# Chi tiết lớp Domain (`lib/domain`)

## 1. Vai trò
Lớp Domain (Domain Layer) là trung tâm của kiến trúc Clean Architecture. Nó chứa các quy tắc nghiệp vụ (Business Rules) thuần túy nhất của ứng dụng, không phụ thuộc vào bất kỳ framework (như Flutter), cơ sở dữ liệu (như Firestore), hay thư viện bên ngoài nào.
Mục đích là để logic nghiệp vụ có thể dễ dàng kiểm thử (Unit Test) và không bị ảnh hưởng khi công nghệ thay đổi.

## 2. Cấu trúc chi tiết

### 📁 `entities/`
Chứa các đối tượng dữ liệu cốt lõi (Core Business Objects) của ứng dụng.
- Đây là các class Dart thuần túy, định nghĩa các thuộc tính và phương thức nghiệp vụ.
- Không chứa các hàm factory liên quan đến JSON hay Firestore (đó là việc của Model ở lớp Data).
- Ví dụ thực tế trong dự án:
  - `patient.dart`: Thực thể Bệnh nhân.
  - `sample.dart`: Thực thể Mẫu bệnh phẩm.
  - `test_order.dart`: Thực thể Lệnh xét nghiệm.
  - `metaphase_image.dart`: Thực thể Ảnh kỳ giữa (Chromosome).

### 📁 `repositories/`
Chứa các **Abstract Class** (Interface) định nghĩa các hành động lấy/ghi dữ liệu.
- Lớp này không chứa code triển khai cụ thể (Implementation). Code triển khai thực tế nằm ở `lib/data/repositories`.
- Giúp lớp Domain không bị phụ thuộc vào cách thức dữ liệu được lưu trữ.

### 📁 `usecases/`
Chứa các trường hợp sử dụng (Use Cases) cụ thể của ứng dụng. Mỗi Use Case thường chỉ thực hiện một hành động nghiệp vụ duy nhất (Single Responsibility).
- Đóng vai trò là cầu nối giữa lớp UI/Logic (Cubit) và lớp Repository.
- Ví dụ thực tế trong dự án:
  - `get_sample_by_id_usecase.dart`: Lấy thông tin mẫu bằng ID.
  - `update_sample_note_usecase.dart`: Cập nhật ghi chú mẫu.
  - Các thư mục con chia theo module như `appointment/`, `patient/`, `specialist/`.

---
Tài liệu này bổ sung chi tiết cho mục `lib/domain` trong @doc/presentation/cu-trc-th-mc-lib-v-kin-trc-ng-dng.
