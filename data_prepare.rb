# 功能描述:从excel中读取手机信息入到数据库中;
# 需要的类库:使用xlrd、xlwt操作excel,使用类库sqlite3来操作sqlite;

require 'rubyXL'
require 'sqlite3'
require 'set'
require 'open-uri'
require 'nokogiri'

class DataPrepare

  def initialize

  end

  # 数据库初始化
  def init_db(db_file_name)

    db = SQLite3::Database.new db_file_name
    db.execute_batch <<-SQL
    DROP TABLE IF EXISTS MOBILE;
    CREATE TABLE IF NOT EXISTS MOBILE(
                      'KEY_WORD' VARCHAR,
                      'MOBILE_NAME' VARCHAR,
                      'SYSTEM_VERSION' VARCHAR,
                      'CPU_VERSION' VARCHAR,
                      'CPU_FREQUENCY' VARCHAR,
                      'RESOLUTION' VARCHAR,
                      'NUMBER_CORE' VARCHAR,
                      'M_RAW' VARCHAR,
                      'M_ROW' VARCHAR
                 );
    SQL

    db
  end

  # TODO 注释清楚参数意义
  def read_keywords_from_excel(file_name, sheet_name)

    book = RubyXL::Parser.parse(file_name)

    keywords = Set.new  #集合,去重

    is_start=false # 标记是否开始处理
    book[sheet_name].each do |row|

      is_start && row && row.cells.each { |cell|
        val = cell&.value
        keywords<<val # TODO 两个左尖括号在数据量比较大的时候会报错的, 需要改成函数调用
      }

      # 寻找第一个非空行认为开始处理
      is_start || (is_start = !row[0].value.empty?)
    end

    keywords

  end

  # TODO 注释清楚参数意义
  def write_keywords_to_db(keywords, db)

    keywords.each { |keyword|
      db.execute("INSERT INTO MOBILE (KEY_WORD) VALUES('#{keyword}')")
    }

  end

  #从数据库中获取keyword的值
  def read_keywords_from_sqlite(db)
    keywords = []

    db.execute('select KEY_WORD from MOBILE').each do |row|
      keywords << row[0]
    end

    keywords
  end

  #爬取页面:找到手机信息所在的参数页面url
  def parse_page(keyword)

    url = "http://search.zol.com.cn/s/all.php?kword=#{URI.escape(keyword)}" #新url,手机查询
    doc = Nokogiri::HTML(open url)
    params = doc.css('.param-more')

    params[0]['href'] unless params.empty?

  end

end


a = DataPrepare.new
db = a.init_db 'data.db'
keywords = a.read_keywords_from_excel('data/moblie.xlsx', 'Sheet1')
a.write_keywords_to_db(keywords, db)
keywords = a.read_keywords_from_sqlite(db)
keywords.each do |cell|
  puts "#{cell}: #{a.parse_page(cell)}"
end

