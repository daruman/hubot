# Description:
#   Backlog to Slack
#
# Notes:
#   BacklogとSlackのIntegration用hubot  
#   Backlogのwebhookから送信されるtype idについては以下参照  
#   [最近の更新の取得 | Backlog API | Nulab Developers](http://developer.nulab-inc.com/ja/docs/backlog/api/2/get-activities)

backlogUrl = process.argv[process.argv.length - 2]
webhookKeyword = process.argv[process.argv.length - 1]

module.exports = (robot) ->
    robot.router.post "/" + webhookKeyword + "/:room", (req, res) ->
        room = req.params.room
        body = req.body

        console.log 'body type = ' + body.type
        console.log 'room = ' + room

        try
            switch body.type
                when 1
                    label = '課題の追加'
                when 2, 3
                    # 「更新」と「コメント」は実際は一緒に使うので、一緒に。
                    label = '課題の更新'
                when 4
                    label = '課題の削除'
                when 5
                    label = 'wikiの追加'
                when 6
                    label = 'wikiの更新'
                when 7
                    label = 'wikiの削除'
                when 8
                    label = '共有ファイルの追加'
                when 9
                    label = '共有ファイルの更新'
                when 10
                    label = '共有ファイルの削除'
                when 11
                    label = 'Subversionコミット'
                when 12
                    label = 'GITプッシュ'
                when 13
                    label = 'GITリポジトリ作成'
                when 14
                    label = '課題をまとめて更新'
                when 15
                    label = 'プロジェクトに参加'
                when 16
                    label = 'プロジェクトから脱退'
                when 17
                    label = 'コメントにお知らせを追加'
                when 18
                    label = 'プルリクエストの追加'
                when 19
                    label = 'プルリクエストの更新'
                when 20
                    label = 'プルリクエストにコメント'
                else
                    return

            # 投稿メッセージを整形
            url = "#{backlogUrl}view/#{body.project.projectKey}-#{body.content.key_id}"
            if body.content.comment?.id?
                url += "#comment-#{body.content.comment.id}"

            message = "*Backlog #{label}*\n"
            message += "[#{body.project.projectKey}-#{body.content.key_id}] - "
            message += "#{body.content.summary} _by #{body.createdUser.name}_\n>>> "
            if body.content.comment?.content?
                message += "#{body.content.comment.content}\n"
            message += "#{url}"

            console.log 'message = ' + message

            # Slack に投稿
            if message?
                robot.messageRoom room, message
                res.end "OK"
            else
                robot.messageRoom room, "Backlog integration error."
                res.end "Error"
        catch error
          robot.send
        res.end "Error"
