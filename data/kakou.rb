#レコード数分の辞書
wc_n=File.read('jbisc.txt').count('*')
data,i=Array.new(wc_n).map{Hash.new},0
duplicate = %w(ISBN NOTE TITLEHEADING AUTHORHEADING)
#Hash化
File.foreach("jbisc.txt"){|row|
  row.chomp!
  unless row=='*'
    key=row.scan(/^([A-Z]+): /)[0][0]
    unless duplicate.include?(key)
      row.sub!(/ : /,"＞") if key=="TR"
      data[i][key.to_sym]=row.delete(key+": ")
    else
      (data[i][key.to_sym]||=[])<<row.delete(key+": ")
    end
  else
    i+=1
  end
}
#書き出し
out=[]
data.each{|dic|
  duplicate.each{|d|dic[d.to_sym]||=[]}
  dic[:TR].sub!(/＞/," : ")
  dic[:TR]=~/\//? dic[:TR].sub!(/\//,"|") : dic[:TR]+="|"
  dic[:PUB].sub!(/,/,"|")
  dic[:PUB].sub!(/\[2004\]$/,"2004")
  dic[:PUB].sub!(/\[2005\]$/,"2005")
  dic[:PUB].sub!(/\[2004.8\]$/,"2004.8")
  dic[:PUB].sub!(/[c]/,"")
  dic[:PUB].sub!(/印刷/,"")
  out<<<<-EOF
#{dic[:NBC]}|\
#{dic[:ISBN].join("＞")}|\
#{dic[:TR]}|\
#{dic[:PUB]}|\
#{dic[:ED]}|\
#{dic[:PHYS]}|\
#{dic[:SERIES]}|\
#{dic[:NOTE].join("＞")}|\
#{dic[:TITLEHEADING].join("＞")}|\
#{dic[:AUTHORHEADING].join("＞")}|\
#{dic[:HOLDINGSRECORD]}|\
#{dic[:HOLDINGPHYS]}|\
#{dic[:HOLDINGLOC]}
EOF
}
->(a){a.each{|b|
  b.gsub!(/"/,'""')
  b.gsub!(/\|("")(.*?)("")(.*?)\|/,'|"\1\2\3\4"|') if b=~/.*\|"".*/
  puts b}}.call(out)
