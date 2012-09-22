def decrypt_in_thumbor(str)
  command = "python -c 'from thumbor.crypto import Cryptor; cr = Cryptor(\"my-security-keymy\"); print cr.decrypt(\"" << str << "\")'"
  result = Array.new
  IO.popen(command) { |f| result.push(f.gets) } 
  result = result.join('').strip
  JSON.parse(result.gsub('"', "@@@").gsub("'", '"').gsub("@@@", '\\"').gsub('True', 'true').gsub('False', 'false').gsub('None', 'null'))
end
