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

    weak var delegate: ExchangeScrollViewDelegate?
    weak var dataSource: ExchangeScrollViewDataSource? {
        didSet {
            createUi()
        }
    }
    
    var activeSlide: CurrencyView? 
    private var slides = [CurrencyView]()
    private var pageControl: UIPageControl!
    private var pagingScrollView: UIScrollView!
    private var numberOfPages: Int {
        return dataSource?.numberOfItems(inScrollView: self) ?? 1
    }
    
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
        createPageControl()
    }
    
    //Initializes the scroll view
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
        loadSlides()
    }
    
    //Initializes the page control and positions it in the bottom of the view
    fileprivate func createPageControl() {
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
    
    //Initializes slides
    fileprivate func loadSlides() {
        guard let source = dataSource?.accountsForItems(inScrollView: self) else { return }
        for pageNumber in 0..<numberOfPages {
            let account = source[pageNumber]
            let slide = generateView()
            slide.tag = pageNumber
            slide.account = account
            slide.delegate = self
            slides.append(slide)
        }
        setSlides()
    }
    
    //Adds and positions all slides in the scroll view. Sets the contentOffset to the middle slide
    fileprivate func setSlides() {
        for pageNumber in 0..<numberOfPages {
            var frame = pagingScrollView.frame
            frame.origin.x = frame.width * CGFloat(pageNumber)
            slides[pageNumber].frame = frame
            pagingScrollView.addSubview(slides[pageNumber])
        }
        pagingScrollView.setContentOffset(CGPoint(x: frame.width, y: 0), animated: false)
        activeSlide = slides[1]
    }
    
    fileprivate func generateView() -> CurrencyView {
        return Bundle.main.loadNibNamed("CurrencyView", owner: nil, options: nil)?.first as! CurrencyView
    }
    
    //rearranges the slides array, in order to have new visible element in the middle position
    fileprivate func reloadSlides(withCurrentSlide slide: Int) {
        // Don't reload if it's not first or last page
        guard (slide != 1) else { return }
        if slide == 0 {
            slides.rearrange(from: slides.count-1, to: 0)
        } else {
            slides.rearrange(from: 0, to: slides.count-1)
        }
        activeSlide = slides[slide]
        pageControl.currentPage = activeSlide!.tag
        resetPages()
        guard let account = activeSlide?.account else { return }
        delegate?.scrollView(self, scrolledToAccount: account)
    }
    
    //removes all slides from the scroll view
    fileprivate func resetPages() {
        for page in slides  {
            page.removeFromSuperview()
        }
        setSlides()
    }
}

extension ExchangeScrollView: CurrencyViewDelegate {
    
    func didReturnAmount(_ amount: Float, fromSlide slide: CurrencyView) {
        guard let pageAccount = slide.account,
        let activeAccount = activeSlide?.account else { return }
        if pageAccount.currency == activeAccount.currency {
            delegate?.scrollView(self, returnedValue: amount, forAccount: activeAccount)
        }
    }

}

extension ExchangeScrollView: UIScrollViewDelegate {
    
    //checks which is the current slide after end of slide animation and rearranges slides
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let slideWidth = scrollView.frame.width
        let slide = floor((scrollView.contentOffset.x - slideWidth / 2) / slideWidth) + 1
        reloadSlides(withCurrentSlide: Int(slide))
    }
    
}
