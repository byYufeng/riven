#!/usr/bin/env python
#coding:utf-8
"""
Author: fsrm
Create Time: 2020-01-12 14:19:54
"""

import sys, os
import time, json, traceback
sys.path.append(".")


def main():
    l = [3,2,5,6,7,3,1,9,4] 
    #l = [1,2,3,4]
    #l = [4,3,2,1]
    print(l)
    quicksort(l, 0, len(l)-1)
    print(sorted(l))
    print(l)

def quicksort(l, left, right):
    #fix
    if left == right:
        return 

    flag = l[left]
    x, y = left+1, right #这种写法会造成后面边界问题，需要fix返回条件，于是优化
    while x<y:
        #print(l[left+1:x],l[x],l[x+1:y],l[y],l[y+1:right+1])
        if l[x] > flag:
            while y>x:
                if l[y] < flag :
                    swap(l, x, y)
                    x += 1
                    y -= 1
                    break
                y -= 1
        else:
            x += 1
    # 结束循环时，x可能大于flag(结束于内层循环)，也可能小于flag(结束于外层循环)
    if l[x] > flag:
        swap(l, left, x-1)
    if l[x] < flag:
        swap(l, left, x)

    print(l[left:x], l[x:right+1], x)
    quicksort(l, left, x-1)
    quicksort(l, x, right)


def swap(l, x, y):
    if x != y:
        l[x] ^= l[y];l[y] ^= l[x];l[x] ^= l[y];


if __name__ == "__main__":
    main()
