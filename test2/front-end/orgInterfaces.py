from tkinter import *
import os

window = Tk()
window.title('BlackChain Querying')
mainframe = Frame(window)

def QueryPublicStuff():
    print('Querying now ... please be patient')
    user = userType.get().lower()
    userId = entry.get()
    print(user + " " + userId)
    r = os.popen('./scripts/query.sh 1 ' + user + ' ' + userId).read()
    print(r)

def QueryPrivateStuff():
    print('Querying now ... please be patient')
    user = userType.get().lower()
    userId = entry.get()
    r = os.popen('./scripts/query.sh 2 ' + user + ' ' + userId).read()
    print(r)



userType = StringVar()
userOptions = {'Airport','CCD','Users'}
userType.set('Users')
menu = OptionMenu(mainframe,userType,*userOptions)
Label(mainframe,text='Select User Type : ').grid(row=0,column=0)
menu.grid(row = 0,column = 1)

Label(mainframe,text='User ID : ').grid(row=1,column=0)
entry = Entry(mainframe)
entry.grid(row = 1,column=1)

button1 = Button(mainframe,text='Query Public Data',command=QueryPublicStuff)
button2 = Button(mainframe,text='Query Private Data',command=QueryPrivateStuff)
button1.grid(row=2,column=0)
button2.grid(row=2,column=1)
mainframe.pack()
window.mainloop()
