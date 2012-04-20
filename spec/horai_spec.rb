# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

def now (year = nil, month = nil, day = nil, hour = nil, minute = nil, second = nil)
  time = DateTime.now
  DateTime.new(year   || time.year,
               month  || time.month,
               day    || time.day,
               hour   || time.hour,
               minute || time.minute,
               second || time.second,
               Rational(9, 24))
end

describe Horai do
  context 'normalization' do
    it "number" do
      Horai.normalize('０１２３４').should === '01234'
    end
    it "alphabet" do
      Horai.normalize('ａｂｃｄｅ').should === 'abcde'
      Horai.normalize('ＡＢＣＤＥ').should === 'ABCDE'
    end
    it "numeric kanji" do
      Horai.normalize('十五').should === '15'
      Horai.normalize('十四万二千三百四十五').should === '142345'
      Horai.normalize('百五十時間後').should === '150時間後'
    end
  end
  context 'parse absolute' do
    before :each do
      @sample_date = DateTime.new(2012, 4, 11, 12, 45, 30, Rational(9, 24))
      @sample_text = @sample_date.strftime('%Y年%m月%d日の%H時%M分%S秒')
    end
    it "%Y年%m月%d日の%H時%M分%S秒" do
      time = Horai.parse(@sample_text)
      time.to_s.should === @sample_date.to_s
    end
    it "half time" do
      time = Horai.parse("1時半")
      time.to_s.should === now(nil, nil, nil, 1, 30, 0).to_s
    end
    it "half minute" do
      time = Horai.parse("1分半後")
      time.to_s.should === (now + 1.5.minute).to_s
    end
    it "half hour and minute" do
      time = Horai.parse("5時間半と1分半後")
      time.to_s.should === (now + 5.5.hour + 1.5.minute).to_s
    end
    it "at night" do
      time = Horai.parse("夜の8時に")
      time.to_s.should === (now(nil, nil, nil, 20, 0, 0)).to_s
    end
    it "at afternoon" do
      time = Horai.parse("午後一時に")
      time.to_s.should === (now(nil, nil, nil, 13, 0, 0)).to_s
    end
    it "at afternoon" do
      time = Horai.parse("PM1時に")
      time.to_s.should === (now(nil, nil, nil, 13, 0, 0)).to_s
    end
    it "at AM and contains *pm*" do
      time = Horai.parse("rpm 6時に")
      time.to_s.should === (now(nil, nil, nil, 6, 0, 0)).to_s
    end
    it "at noon" do
      time = Horai.parse("10日の正午に")
      time.to_s.should === (now(nil, nil, 10, 12, 0, 0)).to_s
    end
  end

  context 'parse relative' do
    it "check" do
      Horai.relative?("10分後").should be_true
      Horai.relative?("10分経ったら").should be_true
      Horai.relative?("10分したら").should be_true
      Horai.relative?("10分").should be_false
      Horai.relative?("10時10分").should be_false
    end
    it "single" do
      time = Horai.parse("10分後")
      time.to_s.should === (now + 10.minute).to_s
    end
    it "tomorrow" do
      time = Horai.parse("明日")
      time.to_s.should === (now + 1.day).to_s
    end
    it "day after tomorrow" do
      time = Horai.parse("明後日")
      time.to_s.should === (now + 2.day).to_s
    end
    it "yesterday" do
      time = Horai.parse("昨日")
      time.to_s.should === (now - 1.day).to_s
    end
    it "day after" do
      time = Horai.parse("10日後")
      time.to_s.should === (now + 10.day).to_s
    end
    it "day and absolute time" do
      time = Horai.parse("明日の10時")
      time.to_s.should === (now(nil, nil, nil, 10, 0, 0) + 1.day).to_s
    end
    it "day after tomorrow and afternoon" do
      time = Horai.parse("明後日の午後5時")
      time.to_s.should === (now(nil, nil, nil, 17, 0, 0) + 2.day).to_s
    end
    it "day after tomorrow and noon" do
      time = Horai.parse("明後日の正午")
      time.to_s.should === (now(nil, nil, nil, 12, 0, 0) + 2.day).to_s
    end
    it "numeric day and absolute time" do
      time = Horai.parse("3日後の12時")
      time.to_s.should === (now(nil, nil, nil, 12, 0, 0) + 3.day).to_s
    end
    it "numeric day and absolute time" do
      time = Horai.parse("3日後の12時45分")
      time.to_s.should === (now(nil, nil, nil, 12, 45, 0) + 3.day).to_s
    end
    it "numeric day and relative time" do
      time = Horai.parse("3日12時間45分後")
      time.to_s.should === (now + 3.day + 12.hour + 45.minute).to_s
    end
    it "half time" do
      time = Horai.parse("1時間半後")
      time.to_s.should === (now + 1.5.hour).to_s
    end
    it "half minute" do
      time = Horai.parse("1分半後")
      time.to_s.should === (now + 1.5.minute).to_s
    end
    it "half hour and minute" do
      time = Horai.parse("5時間半と1分半後")
      time.to_s.should === (now + 5.5.hour + 1.5.minute).to_s
    end
  end
end
