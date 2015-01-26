ans-matchers
============

rspec のマッチャ拡張

* `have_out_of_range_validation`
* `have_association_db_index`
* `have_executable_scope`
* `success_persistance_of`


have_out_of_range_validation
----------------------------

「sql レベルで out of range を起こす値をバリデーションエラーにすること」

```ruby
describe Model do
  it{expect(subject).to have_out_of_range_validation}
  it{expect(subject).to have_out_of_range_validation.except(:my_column,:my_column2)}
  it{expect(subject).to have_out_of_range_validation.force(:my_column,:my_column2)}
  it{expect(subject).to have_out_of_range_validation.as(
    my_column: 10**10
  )}
end
```

全カラムはモデルの columns メソッドを使用して取得する  
保存できる最大長は column オブジェクトから取得する

* except で除外するカラムを列挙できる
* force で除外するカラムに該当する場合でもチェックできる
* as で例外を引き起こすべき値をカラムごとに指定できる

### 指定可能な設定とデフォルト

```ruby
Ans::Matchers.configure do |config|
  config.have_out_of_range_validation.except_columns = [
    :id,
    %r{_id$},
    %r{_type$},
    %r{_status$},
    %r{_fla?g$},
  ]
end
```

* except_columns にデフォルトで無視するカラムを列挙する

have_association_db_index
-------------------------

「association のアクセスで使用されるカラムの index を持つこと」

```ruby
describe Model do
  it{expect(subject).to have_association_db_index}
  it{expect(subject).to have_association_db_index.except(:my_column,:my_column2)}
end
```

全カラムはモデルの columns メソッドを使用して取得する  
`*_id` という名前のカラムに対して index がはられているか確認する

* except で除外するカラムを列挙できる

### 指定可能な設定とデフォルト

```ruby
Ans::Matchers.configure do |config|
  config.have_association_db_index.validate_columns = [
    %r{_id$},
  ]
end
```

* validate_columns にチェックするカラムを列挙する

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

**これは削除予定ですので使用しないように**

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

