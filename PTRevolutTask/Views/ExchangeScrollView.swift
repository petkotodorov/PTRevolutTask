//
//  ExchangeView.swift
//  PTRevolutTask
//
//  Created by Petko Todorov on 10/5/17.
//  Copyright © 2017 Petko Todorov. All rights reserved.
//

import UIKit

protocol ExchangeScrollViewDataSource: class {
    func numberOfItems(inScrollView scrollView: ExchangeScrollView) -> Int
    func accountsForItems(inScrollView scrollView: ExchangeScrollView) -> [Account]
}

protocol ExchangeScrollViewDelegate: class {
    func scrollView(_ scrollView: ExchangeScrollView, scrolledToAccount account: Account)
    func scrollView(_ scrollView: ExchangeScrollView, returnedValue: Float, forAccount: Account)
}

class ExchangeScrollView: UIView {

    weak var dataSource: ExchangeScrollViewDataSource? {
        didSet {
            createUi()
        }
    }
    weak var delegate: ExchangeScrollViewDelegate?
    
    var activePage: CurrencyView? 
    
    private var pagingScrollView: UIScrollView!
    private var numberOfPages: Int {
        return dataSource?.numberOfItems(inScrollView: self) ?? 1
    }
    
    private var pages = [CurrencyView]()
    private var pageControl: UIPageControl!
    
    //MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        createUi()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createUi()
    }
    
    //MARK: UI creation and update
    fileprivate func createUi() {
        guard dataSource != nil else { return }
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.6
        layer.shadowOffset = CGSize(width: 1, height: 1)
        
        
        createScrollView()
        loadPages()
        
        pageControl = UIPageControl()
        addSubview(pageControl)
        pageControl.currentPage = 1
        pageControl.numberOfPages = 3
        pageControl.tintColor = .white
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
    }
    
    fileprivate func createScrollView() {
        pagingScrollView = UIScrollView()
        pagingScrollView.delegate = self
        pagingScrollView.isPagingEnabled = true
        pagingScrollView.showsHorizontalScrollIndicator = false
        pagingScrollView.bounces = false
        addSubview(pagingScrollView)
        pagingScrollView.frame = bounds
        pagingScrollView.contentSize =
            CGSize(width: pagingScrollView.frame.width * CGFloat(numberOfPages),
                   height: pagingScrollView.frame.height)
    }
    
    fileprivate func loadPages() {
        guard let source = dataSource?.accountsForItems(inScrollView: self) else { return }
        for pageNumber in 0..<numberOfPages {
            let account = source[pageNumber]
            let page = generateView()
            page.tag = pageNumber
            page.account = account
            page.delegate = self
            pages.append(page)
        }
        setPages()
    }
    
    
    fileprivate func setPages() {
        for pageNumber in 0..<numberOfPages {
            var frame = pagingScrollView.frame
            frame.origin.x = frame.width * CGFloat(pageNumber)
            pages[pageNumber].frame = frame
            pagingScrollView.addSubview(pages[pageNumber])
        }
        pagingScrollView.setContentOffset(CGPoint(x: frame.width, y: 0), animated: false)
        activePage = pages[1]
    }
    
    fileprivate func generateView() -> CurrencyView {
        return Bundle.main.loadNibNamed("CurrencyView", owner: nil, options: nil)?.first as! CurrencyView
    }

    fileprivate func reloadPages(withCurrentPage page: Int) {
        // Don't reload if it's not first or last page
        guard (page != 1) else { return }
        if page == 0 {
            pages.rearrange(from: pages.count-1, to: 0)
        } else {
            pages.rearrange(from: 0, to: pages.count-1)
        }
        activePage = pages[page]
        pageControl.currentPage = activePage!.tag
        resetPages()
        guard let account = activePage?.account else { return }
        delegate?.scrollView(self, scrolledToAccount: account)
    }
    
    fileprivate func resetPages() {
        for page in pages  {
            page.removeFromSuperview()
        }
        setPages()
    }
}

extension ExchangeScrollView: CurrencyViewDelegate {
    
    func didReturnValue(_ value: Float, fromPage page: CurrencyView) {
        guard let pageAccount = page.account,
        let activeAccount = activePage?.account else { return }
        if pageAccount.currency == activeAccount.currency {
            delegate?.scrollView(self, returnedValue: value, forAccount: activeAccount)
        }
    }
    
}

extension ExchangeScrollView: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.width
        let page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1
        reloadPages(withCurrentPage: Int(page))
    }
    
}
