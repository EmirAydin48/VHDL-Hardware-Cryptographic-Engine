**Mevcut Diller:** [English](README.md) | [Türkçe](README_TR.md)


# 🔐 FPGA Tabanlı Donanımsal Kriptografik Motor (Eğitimsel)

![Status](https://img.shields.io/badge/Status-Completed-success)
![Tech](https://img.shields.io/badge/Language-VHDL-blue)
![Board](https://img.shields.io/badge/Hardware-Basys3-orange)
![Project Type](https://img.shields.io/badge/Project_Type-Academic_Research-yellow)
![Security_Level](https://img.shields.io/badge/Security-Educational_Proof_of_Concept-red)

---

## Genel Bakış

Bu proje, özel kriptografik ilkelere dayalı bir sistemin FPGA üzerinde gerçekleştirilmesine odaklanmaktadır. Projenin temel amacı; özellikle Doğrusal Olmayan Geri Beslemeli Kaydırma Yazmaçları ve Dengesiz Feistel Ağları gibi teorik şifreleme mimarilerinin nasıl çalıştığını araştırmaktır.

Yürütmenin yazılım modellerinden Artix-7 FPGA yapısına eşlenmesiyle, bu çalışma kriptografik sistemlerde donanım hızlandırma, boru hatlı paralellik ve gerçek zamanlı saat senkronizasyonu ilkelerini göstermektedir.

---

## Temel Tasarım Özellikleri

* **Hibrit Kriptografik Mimari**
  * Akış şifrelerinin hız avantajını, Blok şifrelerin yapısal özellikleriyle birleştiren, Dengesiz Feistel Ağı tabanlı özel bir şifreleme yapısı uygulanmıştır.
* **Doğrusal Olmayan Anahtar Üretimi**
  * Doğrusal kriptoanalize karşı mantık seviyesinde direnç göstermek amacıyla Boolean karışım fonksiyonları kullanan 7-bit NLFSR tasarlanmıştır.
* **Tersinir Mantık Çekirdeği**
  * Feistel özelliği  
   ($A \oplus B \oplus B = A$)
    sayesinde, aynı donanım mantık yapısı hem şifreleme hem de çözme modlarında kullanılabilmektedir.

---

## Sistem Mimarisi
*UART arayüzü yalnızca test ve doğrulama amacıyla kullanılmakta olup, kriptografik tasarımın bir parçası değildir.*

Sistem, sürekli çalışan boru hatlı bir veri yolu yapısına sahiptir:

### 1. Giriş Arayüzü (`UART_RX`)
* **Protokol:** Standart RS-232 Seri Haberleşme (9600 Baud, 8N1)
* **Fonksiyon:** PC/Klavye üzerinden gelen seri veriyi paralel 8-bit baytlara dönüştürür
* **Senkronizasyon:** Şifreleme çekirdeğini tam olarak bir saat çevrimi boyunca tetikleyen bir “Data Valid” darbesi üretir

### 2. Çekirdek Motor (`Top_Level.vhd`)
* **Anahtar Üretimi:** NLFSR, doğrusal olmayan geri besleme polinomu ile durumunu günceller
* **Bölme:** 7-bit ASCII giriş verisi “Anchor” (3 bit) ve “Target” (4 bit) segmentlerine ayrılır
* **Karıştırma:** Anchor ve anahtar, Boolean karıştırma fonksiyonuna girer ve çıkan sonuç Target ile XOR’lanır

### 3. Çıkış Görselleştirme (`TDM_Driver`)
* **Teknik:** Görsel Kalıcılık
* **Mekanizma:** 4 haneli anotlar 250 Hz frekansla taranarak tüm göstergelerin aynı anda aktif olduğu izlenimi oluşturulur; böylece pin ve güç tüketimi azaltılır

---

## Teknik Gerçekleme Detayları

#### 1. Feistel Ağı (Difüzyon)
Tersinirliği koruyarak karmaşık ve terslenemez karıştırma fonksiyonlarının kullanılabilmesi için Feistel yapısı tercih edilmiştir.

* **Mantık:**
  $$Target_{new} = Target_{old} \oplus F(Anchor, Key)$$
  $$Anchor_{new} = Anchor_{old}$$
* **Donanım Verimliliği:** Anchor korunarak, çözme işlemi aynı mantığın tekrar uygulanmasıyla gerçekleştirilir. Bu yaklaşım, ayrı şifreleme/çözme devrelerine kıyasla FPGA LUT kullanımını yaklaşık %40 oranında azaltmıştır.

---

#### 2. Doğrusal Olmayan Geri Beslemeli Kaydırma Yazmacı
Standart LFSR yapıları doğrusal cebir tabanlı saldırılara açıktır. Bu projede anahtar üretici NLFSR yapısına yükseltilmiştir.

* **Yükseltme:** XOR tap’leri yerine AND/OR kapıları içeren geri besleme yolları kullanılmıştır
* **Matematiksel Sonuç:** Üretilen anahtar dizisinin doğrusal karmaşıklığı artırılmış, başlangıç durumu bilinmeden tahmin edilmesi zorlaştırılmıştır

---

## Tasarım Evrimi

Proje, teorik mantık tasarımından fiziksel donanım uygulamasına doğru aşamalı olarak geliştirilmiştir.

| Aşama | Mimari | Temel Mühendislik Kazanımı |
| :--- | :--- | :--- |
| **I** | **Doğrusal Akış** | 4-bit LFSR ile temel XOR şifreleme doğrulandı |
| **II** | **Permütasyon** | Bit konumlarını karıştırmak için P-Box eklendi |
| **III** | **ASCII Genişleme** | Tam metin desteği için 7-bit veri yolu |
| **IV** | **Doğrusal Olmayan Çekirdek** | LFSR → NLFSR geçişi |
| **V** | **Feistel Ağı** | Tersinir blok mimarisine geçiş |
| **VI** | **FPGA Uyarlaması** | VHDL sentezi, UART ve TDM entegrasyonu |

---

## 🔌 Donanım Pin Bağlantıları (Basys 3)

| Bileşen | Sinyal Adı | FPGA Pini | Açıklama |
| :--- | :--- | :--- | :--- |
| **Sistem** | `CLK` | W5 | 100 MHz Dahili Saat |
| **UART RX** | `RsRx` | B18 | Seri Veri Girişi (USB) |
| **UART TX** | `RsTx` | A18 | Seri Veri Çıkışı (USB) |
| **LED’ler** | `led[0-6]` | U16...U19 | İkili Şifreli Veri |
| **7-Seg Anot** | `an[0-3]` | U2...W4 | Hane Seçimi (Aktif Düşük) |
| **7-Seg Katot** | `seg[0-6]` | W7...U7 | Segment Verisi (A–G) |

---

**Uyarı:** Bu proje, kriptografik ilkelerin donanım seviyesinde uygulanmasını inceleyen araştırma amaçlı bir çalışmadır. NLFSR ve Feistel ağlarının mantığını göstermektedir ancak üretim seviyesinde güvenlik için denetlenmiş veya sertifikalandırılmış değildir.

---

## 🎥 Gösterim

![Comp 1](https://github.com/user-attachments/assets/81680fa6-209f-497b-b98d-d26a630c2d0d)

![Comp 2](https://github.com/user-attachments/assets/718df52b-36e7-4e34-ab30-cfd52f78b724)

---
