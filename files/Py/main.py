import matplotlib as m
import matplotlib.pyplot as p
import numpy as n

x = n.linspace(-20,10,1000)

def f(x):
    #Write the function
    pass

m.use('TkAgg')

#Creating A Graph Object
class SetGraph():
    def __init__(self,xaxis:str,yaxis:str,x,y):
        self.xaxis = xaxis
        self.yaxis = yaxis
        self.x=x
        self.y=y
        p.xlabel(self.xaxis)
        p.ylabel(self.yaxis)
        self.fig, self.ax = p.subplots()

    def plotg(self):
        self.ax.plot(self.x,self.y)

    def export(self,name = "graph",idpi = 400):
        self.fig.savefig(fname=name,dpi=idpi)

Graph1 = SetGraph("Time","Displacement",x,n.sin(x))
Graph2 = SetGraph("Time","Displacement",x,x)


#Plotting the Graph
Graph1.plotg()
Graph2.plotg()
Graph1.export("hi.png",600)
Graph2.export("hello.png",600)

p.show()
