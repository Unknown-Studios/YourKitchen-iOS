//
//  PageViewController.swift
//  Pages
//
//  Created by Nacho Navarro on 03/11/2019.
//  Copyright © 2019 nachonavarro. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import SwiftUI
import UIKit

/// The UIPageViewController in charge of the pages.
@available(iOS 13.0, *)
struct PageViewController: UIViewControllerRepresentable {
    @Binding var currentPage: Int

    var navigationOrientation: UIPageViewController.NavigationOrientation
    var transitionStyle: UIPageViewController.TransitionStyle
    var swipe: Bool
    var controllers: [UIViewController]

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageViewController = UIPageViewController(
            transitionStyle: transitionStyle,
            navigationOrientation: navigationOrientation
        )

        pageViewController.dataSource = context.coordinator
        pageViewController.delegate = context.coordinator

        context.coordinator.parent = self

        return pageViewController
    }

    func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
        let previousPage = context.coordinator.parent.currentPage
        context.coordinator.parent = self

        pageViewController.setViewControllers(
            [controllers[currentPage]],
            direction: currentPage - previousPage > 0 ? .forward : .reverse,
            animated: false
        )
    }

    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: PageViewController

        init(_ pageViewController: PageViewController) {
            parent = pageViewController
        }

        func pageViewController(
            _: UIPageViewController,
            viewControllerBefore viewController: UIViewController
        ) -> UIViewController? {
            guard let index = parent.controllers.firstIndex(of: viewController) else {
                return nil
            }
            guard index - 1 >= 0 else {
                return nil
            }
            if !parent.swipe {
                return nil
            }
            return parent.controllers[index - 1]
        }

        func pageViewController(
            _: UIPageViewController,
            viewControllerAfter viewController: UIViewController
        ) -> UIViewController? {
            guard let index = parent.controllers.firstIndex(of: viewController) else {
                return nil
            }
            guard index + 1 < parent.controllers.count else {
                return nil
            }
            if !parent.swipe {
                return nil
            }
            return parent.controllers[index + 1]
        }

        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating _: Bool, previousViewControllers _: [UIViewController], transitionCompleted completed: Bool) {
            if completed,
               let visibleViewController = pageViewController.viewControllers?.first,
               let index = parent.controllers.firstIndex(of: visibleViewController) {
                parent.currentPage = index
            }
        }
    }
}
