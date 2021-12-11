# enconding utf-8
# frozen_string_literal: true
require 'csv'

# 位置参照情報
POS_DATA_FILES = [
  'data1/32_2020.csv', # （大字・町丁目レベル）
  'data2/32_2020.csv'  # （街区レベル）メモ: 街区レベルには無い市町村がある
]

# 簡便な2点間の尺度（使わない）
def distance1(lat1, lon1, lat2, lon2)
  Math.sqrt((lat1 - lat2)**2 + (lon1 - lon2)**2)
end

# 赤道半径
EQUATOR_RADIUS = 6378137.0

# 2点間の距離（球面三角法）
def distance(lat1, lon1, lat2, lon2)
  # ラジアンに変換
  rLat1 = lat1 * Math::PI / 180
  rLon1 = lon1 * Math::PI / 180
  rLat2 = lat2 * Math::PI / 180
  rLon2 = lon2 * Math::PI / 180
          
  # 算出
  avrLat = (rLat1 - rLat2) / 2
  avrLon = (rLon1 - rLon2) / 2
  distance =
    EQUATOR_RADIUS * 2 * Math.asin(
      Math.sqrt(Math.sin(avrLat)**(2) + Math.cos(rLat1) * Math.cos(rLat2) * Math.sin(avrLon)**(2))
    )
  return distance / 1000
end

def search(latitude, longitude)
  dist, pos = nil, nil

  POS_DATA_FILES.each do |pos_data_file|
    CSV.foreach(pos_data_file, encoding: "cp932:utf-8", headers: true) do |row|
      _dist = distance(row["緯度"].to_f, row["経度"].to_f, latitude, longitude)

      if dist.nil? || _dist < dist
        dist, pos = _dist, row
      end
    end
  end

  return pos, dist
end

latitude = 35.496314
longitude = 133.072193

pos, dist = search(latitude, longitude)

puts "都道府県名:\t#{pos["都道府県名"]}"
puts "市区町村名:\t#{pos["市区町村名"]}"
puts "大字町丁目名:\t#{pos["大字・丁目名"] || pos["大字町丁目名"]}"
puts "小字・通称名:\t#{pos["小字・通称名"]}"
puts "街区符号・地番:\t#{pos["街区符号・地番"]}"
puts "基点からの距離(KM):\t#{format("%.3f", dist)}"
