ans-matchers
============

rspec のマッチャ拡張

* `have_out_of_range_validation`
* `success_persistance_of`
* `have_executable_scope`


have_out_of_range_validation(columns)
----------------------------------

「sql レベルで out of range を起こす値をバリデーションエラーにすること」

    describe Model do
      it{should have_out_of_range_validation}
    end

全カラムはモデルの columns メソッドを使用して取得する  
保存できる最大長は column オブジェクトから取得する

自動で取得した最大長を上書きしたい場合は columns を指定する

例)

    describe Model do
      it{should have_out_of_range_validation(name: "a"*256)}
    end

success_persistance_of の全カラム版

primary カラムは除外されるが、その他のカラムを除外することはできない


have_executable_scope(:scope).params("arg1","arg2").by_sql(sql)
---------------------------------------------------------------

「実行可能なスコープが存在すること」

    describe Model do
      subject{Model}

      it{should have_executable_scope(:scope).to_sql(<<SQL)}
        SELECT
        `table`.*
      FROM
          `table`
        WHERE
        `table`.`column` = 'value'
    SQL

    end

`to_sql` で指定した文字列と `scope.to_sql` で返った文字列を比較する

sql は空白をまとめて比較される

空白も含めて完全一致で比較する場合は `strict!` メソッドを使用する

    describe Model do
      subject{Model}

      it{should have_executable_scope(:scope).strict!.to_sql("".tap{|sql|
        sql <<  "SELECT `table`.* FROM `table` "
        sql << " WHERE `table`.`column` = 'value'"
      })}
    end

スコープにパラメータを渡す場合は `params` メソッドを使用する

    describe Model do
      subject{Model}

      it{should have_executable_scope(:scope).params("a","b","c").to_sql(<<SQL)}
        SELECT
        `table`.*
      FROM
          `table`
        WHERE
        `table`.`column` = 'a'
      AND
        `table`.`column` = 'b'
      AND
        `table`.`column` = 'c'
    SQL

    end


success_persistance_of(:attribute)
----------------------------------

「保存に成功すること」

    describe Model do
      it{should_not success_persistance_of(:name).values(["a"*256])}
    end

データベースに保存できないデータを指定して、 `should_not` でマッチさせることを想定している

`values` メソッドで、値を配列で指定する

例)

    describe Model do
      it{should_not success_persistance_of(:name).values([nil])}      # not null カラム
      it{should_not success_persistance_of(:name).values(["a", "a"])} # unique カラム
      it{should_not success_persistance_of(:name).values(["a"*256])}  # varchar(255)
      it{should_not success_persistance_of(:name).values([10**10])}   # int(9)
    end

他のカラムはすべて nil で保存される

他のカラムにデフォルトを与える場合は subject 句を定義する

例)

    describe Model do
      subject{Model.new FactoryGirl.attributes_for(:model)}

      it{should_not success_persistance_of(:name).values([nil])}      # not null カラム
      it{should_not success_persistance_of(:name).values(["a", "a"])} # unique カラム
      it{should_not success_persistance_of(:name).values(["a"*256])}  # varchar(255)
      it{should_not success_persistance_of(:name).values([10**10])}   # int(9)
    end

