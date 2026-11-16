# ১৪ সেকেন্ড ভিডিও কাটার — Termux + GitHub

এই প্রজেক্টটি Android-এর Termux-এ চলে। প্রতি ১৫ সেকেন্ডের চক্রে প্রথম ১৪ সেকেন্ড রাখে এবং পরের ১ সেকেন্ড বাদ দেয়:

- 0–14s রাখা
- 14–15s বাদ
- 15–29s রাখা
- 29–30s বাদ
- এভাবে ভিডিওর শেষ পর্যন্ত

শেষে সব MP4 ক্লিপ একটি ZIP ফাইলে প্যাক করে।

## ১) GitHub-এ আপলোড

1. GitHub-এ নতুন Public repository তৈরি করো, যেমন `14s-video-cutter`।
2. এই ZIP-এর ভেতরের `cut_video.sh` এবং `README.md` repository-তে Upload files দিয়ে আপলোড করো।
3. Commit changes চাপো।

## ২) Termux-এ একবারের সেটআপ

Termux খুলে একে একে চালাও:

```bash
termux-setup-storage
pkg update -y
pkg install git ffmpeg zip -y
```

## ৩) GitHub থেকে নামাও

`YOUR-USERNAME` ও `YOUR-REPO` নিজের GitHub username/repository দিয়ে বদলাও:

```bash
cd ~
git clone https://github.com/YOUR-USERNAME/YOUR-REPO.git
cd YOUR-REPO
chmod +x cut_video.sh
```

## ৪) ভিডিও কাটো

উদাহরণ—Download ফোল্ডারের `movie.mp4`:

```bash
bash cut_video.sh "/sdcard/Download/movie.mp4"
```

ডিফল্ট নিয়ম ১৪ সেকেন্ড রাখবে + ১ সেকেন্ড বাদ দেবে।

নিজের মতো সময় দিতে চাইলে:

```bash
bash cut_video.sh "/sdcard/Download/movie.mp4" 14 1
```

আউটপুট একই জায়গায় তৈরি হবে:

- `movie_clips/` — আলাদা MP4 ক্লিপ
- `movie_clips.zip` — সব ক্লিপের ZIP

## গুরুত্বপূর্ণ

- কাজটি ফোনেই FFmpeg দিয়ে হয়; ভিডিও কোনো ওয়েবসাইটে আপলোড হয় না।
- ৫–১০ GB ভিডিওতে পর্যাপ্ত খালি স্টোরেজ ও RAM দরকার। ফোন গরম হতে পারে এবং কাজ দীর্ঘ সময় নিতে পারে।
- স্ক্রিন বন্ধ/Termux বন্ধ করলে Android কাজ থামিয়ে দিতে পারে। Termux-কে ব্যাটারি অপ্টিমাইজেশন থেকে বাদ দাও; দীর্ঘ কাজের সময় ফোন চার্জে ও ঠান্ডা জায়গায় রাখো।
- স্ক্রিপ্ট ভিডিও পুনরায় encode করে, তাই সময় বেশি লাগে; `-crf 18` উচ্চ মানের আউটপুটের জন্য। অরিজিনাল ফাইল পরিবর্তন বা মুছে ফেলা হয় না।
- এই টুলে ভিডিওর শেষ অংশ যদি ১৪ সেকেন্ডের কম থাকে, সেটুকুও শেষ ক্লিপ হিসেবে রাখা হবে।
