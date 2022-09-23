public class UpdateParentAccount implements Queueable {

    private List<Account> accountList;
    private ID parent;

    public UpdateParentAccount(List<Account> records, ID id) {
        this.accountList = records;
        this.parent = id;
    }

    public void execute(QueueableContext context) {
        for (Account account_i : accountList) {
            account_i.ParentId = parent;
        }
        update accountList;
    }
}