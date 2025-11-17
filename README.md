# 📦 Sync FIFO Designs (Pointer-based & Counter-based)

Repository này chứa hai thiết kế FIFO đồng bộ (Synchronous FIFO) được cài đặt bằng Verilog:

* **`sync_fifo_ptr`** — FIFO sử dụng **pointer** để phát hiện FULL/EMPTY
* **`sync_fifo_cnt`** — FIFO sử dụng **counter** để phát hiện FULL/EMPTY

Hai module đều được viết đơn giản, rõ ràng, dễ mô phỏng và phù hợp cho FPGA/ASIC hoặc mục đích học tập.
## 🧩 1. Tổng quan FIFO

FIFO (First-In First-Out) là bộ đệm mà dữ liệu ra theo đúng thứ tự vào.
Trong thiết kế phần cứng, FIFO được dùng trong:

* Pipeline và buffer dữ liệu giữa các block
* Giao tiếp UART/SPI/I2C
* Xử lý streaming (video, audio, image)
* Cân bằng tốc độ giữa producer/consumer
* Đồng bộ clock domain (ở FIFO async)

Repo này tập trung vào **FIFO đồng bộ (sync)** chạy cùng 1 clock.

## 📁 2. Danh sách module

### ✅ `sync_fifo_ptr.sv` — Pointer-based FIFO

**Cách phát hiện trạng thái:**

* `empty` khi `wr_ptr == rd_ptr`
* `full` khi `wr_ptr_next == rd_ptr`

**Đặc điểm:**

* Không dùng counter → tiết kiệm tài nguyên
* Rất phổ biến trong ASIC/FPGA
* Đơn giản hóa logic write/read
### ✅ `sync_fifo_cnt.sv` — Counter-based FIFO

**Cách phát hiện trạng thái:**

* `empty` khi `count == 0`
* `full` khi `count == DEPTH`

**Đặc điểm:**

* Dễ kiểm soát số lượng phần tử
* Thuận tiện để thêm `almost_full` / `almost_empty`
* Code rõ ràng, trực quan
## ⚙️ 3. Tham số chung (Parameters)

| Tên      | Ý nghĩa                                   |
| -------- | ----------------------------------------- |
| `WIDTH`  | Số bit cho mỗi phần tử dữ liệu            |
| `DEPTH`  | Số lượng phần tử trong FIFO               |
| `ADDR_W` | Số bit địa chỉ, tính bằng `$clog2(DEPTH)` |
| `CNT_W`  | Số bit counter, dùng trong FIFO counter   |
## 🧱 4. Mô tả hoạt động

### 🔹 Pointer-based FIFO

Dùng hai con trỏ:

* `wr_ptr` — trỏ đến ô sẽ ghi
* `rd_ptr` — trỏ đến ô sẽ đọc

**Wrap-around** khi đạt cuối FIFO.

Full khi write pointer **chuẩn bị** đè lên read pointer.
### 🔹 Counter-based FIFO

Dùng bộ đếm phần tử:

* Tăng khi write
* Giảm khi read
* Không đổi khi vừa write vừa read

Pointer vẫn cần để truy cập memory.
## 🆚 5. So sánh hai kiến trúc

| Tiêu chí              | Pointer FIFO  | Counter FIFO        |
| --------------------- | ------------- | ------------------- |
| Tài nguyên            | Ít hơn        | Nhiều hơn (counter) |
| Logic FULL/EMPTY      | Phức tạp hơn  | Đơn giản            |
| Dễ debug              | Trung bình    | Dễ                  |
| Dùng trong async FIFO | ✔ Rất phù hợp | ✘ Không phù hợp     |
| Thêm almost_full      | Khó           | Dễ                  |
## 🧪 6. Mô phỏng (Simulation)

Ví dụ chạy bằng Icarus Verilog:

```sh
iverilog -o fifo_ptr sync_fifo_ptr.v sync_fifo_ptr_tb.v
vvp fifo_ptr

iverilog -o fifo_cnt sync_fifo_cnt.v sync_fifo_cnt_tb.v
vvp fifo_cnt
```

Testbench cần kiểm thử:

* Ghi liên tục đến FULL
* Đọc liên tục đến EMPTY
* Ghi + đọc đồng thời
* Test wrap-around pointer
* Đảm bảo không ghi khi FULL, không đọc khi EMPTY
## 📂 7. Cấu trúc repo

```
/sync-fifo
│
├── sync_fifo_ptr.v
├── sync_fifo_cnt.v
│
├── sync_fifo_ptr_tb.v      (optional)
├── sync_fifo_cnt_tb.v      (optional)
│
└── README.md
```

## 📜 8. Kết quả thực hiện
Kết quả dạng sóng
<img width="1427" height="323" alt="image" src="https://github.com/user-attachments/assets/892e64fa-e13b-4e95-8408-596db82e4412" />

Netlist
<img width="1422" height="712" alt="image" src="https://github.com/user-attachments/assets/ebd59f10-f53e-4075-b06f-8583e8051081" />





