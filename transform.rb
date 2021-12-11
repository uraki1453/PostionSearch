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

def transform(in_file_name, out_file_name)
  pos_csv_files = POS_DATA_FILES.map do |file_name|
    CSV.read(file_name, encoding: "cp932:utf-8", headers: true)
  end
  in_file = CSV.read(in_file_name, encoding: "cp932:utf-8", headers: true)
  out_file = CSV.open(out_file_name, "wb", encoding: "cp932")

  out_file << [
    *in_file.headers,
    "都道府県名",
    "市区町村名",
    "大字・丁目名",
    "小字・通称名",
    "街区符号・地番",
    "基点からの距離(KM)"
  ]
  
  in_file.each do |row|
    dist, pos = nil, nil
    pos_csv_files.each do |pos_csv| 
      pos_csv.each do |_pos|
        _dist = distance(_pos["緯度"].to_f, _pos["経度"].to_f, row["緯度"].to_f, row["経度"].to_f)

        if dist.nil? || _dist < dist
          dist, pos = _dist, _pos
        end
      end
    end

    out_file << [
      *row.to_h.values,
      pos["都道府県名"],
      pos["市区町村名"],
      pos["大字・丁目名"] || pos["大字町丁目名"],
      pos["小字・通称名"],
      pos["街区符号・地番"],
      format("%.3f", dist)
    ]
  end
end

transform("in_file.csv", "out_file.csv")